# frozen_string_literal: true

module Bulkrax
  # This module is responsible for providing the means of querying Solr for the appropriate works,
  # collections, and file sets for an export of entries.
  #
  # @see .for
  module ParserExportRecordSet
    # @api public
    #
    # A factory method for returning an object that can yield each id and associated entry_class as
    # well as return the count of objects in the record set.
    #
    # @param parser [Bulkrax::ApplicationParser]
    # @param export_from [String]
    #
    # @return [#each, #count] An object, likely a descendant of
    #         {Bulkrax::CurrentParserRecordSet::Base} that responds to {Base#count} and
    #         {Base#each}.
    def self.for(parser:, export_from:)
      "Bulkrax::ParserExportRecordSet::#{export_from.classify}".constantize.new(parser: parser)
    end

    # @abstract
    #
    # @note This has {#each} and {#count} but is not an Enumerable.  But because it has these two
    #       methods that echo {Array}, we can do some lovely mocking and stubbing in those classes
    #       dependent on this file.  :)
    class Base
      def initialize(parser:)
        @parser = parser
      end
      attr_reader :parser
      private :parser

      delegate :limit_reached?, :work_entry_class, :collection_entry_class, :file_set_entry_class, :importerexporter, to: :parser
      private :limit_reached?, :work_entry_class, :collection_entry_class, :file_set_entry_class, :importerexporter

      # @return [Integer]
      def count
        sum = works.count + collections.count + file_sets.count
        return sum if limit.zero?
        return limit if sum > limit
        return sum
      end

      # Yield first the works, then collections, then file sets.  Once we've yielded as many times
      # as the parser's limit, we break the iteration and return.
      #
      # @yieldparam id [String] The ID of the work/collection/file_set
      # @yieldparam entry_class [Class] The parser associated entry class for the
      #             work/collection/file_set.
      #
      # @note The order of what we yield has been previously determined.
      def each
        counter = 0

        works.each do |work|
          break if limit_reached?(limit, counter)
          yield(work.fetch('id'), work_entry_class)
          counter += 1
        end

        return if limit_reached?(limit, counter)

        collections.each do |collection|
          break if limit_reached?(limit, counter)
          yield(collection.fetch('id'), collection_entry_class)
          counter += 1
        end

        return if limit_reached?(limit, counter)

        file_sets.each do |file_set|
          break if limit_reached?(limit, counter)
          yield(file_set.fetch('id'), file_set_entry_class)
          counter += 1
        end
      end

      private

      # Why call these candidates and not the actual file_set_ids?  Because of implementation
      # details of Hyrax.  What are those details?  The upstream application (as of v2.9.x) puts
      # child works into the `file_set_ids_ssim` field.  So we have a mix of file sets and works in
      # that property.
      #
      # @see #file_sets
      def candidate_file_set_ids
        @candidate_file_set_ids ||= works.flat_map { |work| work.fetch("#{Bulkrax.file_model_class.to_s.underscore}_ids_ssim", []) }
      end

      # @note Specifically not memoizing this so we can merge values without changing the object.
      #
      # No sense attempting to query for more than the limit.
      def query_kwargs
        { fl: "id,#{Bulkrax.file_model_class.to_s.underscore}_ids_ssim", method: :post, rows: row_limit }
      end

      # If we have a limit, we need not query beyond that limit
      def row_limit
        return 2_147_483_647 if limit.zero?
        limit
      end

      def limit
        parser.limit.to_i
      end

      alias works_query_kwargs query_kwargs
      alias collections_query_kwargs query_kwargs

      def extra_filters
        output = ""
        if importerexporter.start_date.present?
          start_dt = importerexporter.start_date.to_datetime.strftime('%FT%TZ')
          finish_dt = importerexporter.finish_date.present? ? importerexporter.finish_date.to_datetime.end_of_day.strftime('%FT%TZ') : "NOW"
          output += " AND system_modified_dtsi:[#{start_dt} TO #{finish_dt}]"
        end
        output += importerexporter.work_visibility.present? ? " AND visibility_ssi:#{importerexporter.work_visibility}" : ""
        output += importerexporter.workflow_status.present? ? " AND workflow_state_name_ssim:#{importerexporter.workflow_status}" : ""
        output
      end

      def works
        @works ||= ActiveFedora::SolrService.query(works_query, **works_query_kwargs)
      end

      def collections
        @collections ||= if collections_query
                           ActiveFedora::SolrService.query(collections_query, **collections_query_kwargs)
                         else
                           []
                         end
      end

      SOLR_QUERY_PAGE_SIZE = 512

      # @note In most cases, when we don't have any candidate file sets, there is no need to query SOLR.
      #
      # @see Bulkrax::ParserExportRecordSet::Importer#file_sets
      #
      # Why can't we just use the candidate_file_set_ids?  Because Hyrax is pushing child works into the
      # `file_set_ids_ssim` field.
      #
      # For v2.9.x of Hryax; perhaps this is resolved.
      #
      # @see https://github.com/scientist-softserv/britishlibrary/issues/289
      # @see https://github.com/samvera/hyrax/blob/64c0bbf0dc0d3e1b49f040b50ea70d177cc9d8f6/app/indexers/hyrax/work_indexer.rb#L15-L18
      def file_sets
        @file_sets ||= if candidate_file_set_ids.empty?
                         []
                       else
                         results = []
                         candidate_file_set_ids.each_slice(SOLR_QUERY_PAGE_SIZE) do |ids|
                           fsq = "has_model_ssim:#{Bulkrax.file_model_class} AND id:(\"" + ids.join('" OR "') + "\")"
                           fsq += extra_filters if extra_filters.present?
                           results += ActiveFedora::SolrService.query(
                             fsq,
                             { fl: "id", method: :post, rows: ids.size }
                           )
                         end
                         results
                       end
      end

      def solr_name(base_name)
        if Module.const_defined?(:Solrizer)
          ::Solrizer.solr_name(base_name)
        else
          ::ActiveFedora.index_field_mapper.solr_name(base_name)
        end
      end
    end

    class All < Base
      def works_query
        "has_model_ssim:(#{Bulkrax.curation_concerns.join(' OR ')}) #{extra_filters}"
      end

      def collections_query
        "has_model_ssim:Collection #{extra_filters}"
      end
    end

    class Collection < Base
      def works_query
        "member_of_collection_ids_ssim:#{importerexporter.export_source} #{extra_filters} AND " \
        "has_model_ssim:(#{Bulkrax.curation_concerns.join(' OR ')})"
      end

      def collections_query
        "(id:#{importerexporter.export_source} #{extra_filters}) OR " \
        "(has_model_ssim:Collection AND member_of_collection_ids_ssim:#{importerexporter.export_source})"
      end
    end

    class Worktype < Base
      def works_query
        "has_model_ssim:#{importerexporter.export_source} #{extra_filters}"
      end

      def collections_query
        nil
      end
    end

    class LocalCollection < Base
      def works_query
        "local_collection_name_tesim:*#{local_coll_id} #{extra_filters}"
      end

      def local_coll_id
        importerexporter.export_source.split("/").last
      end

      def collections_query
        nil
      end
    end

    class Importer < Base
      private

      delegate :work_identifier, to: :parser
      private :work_identifier

      def extra_filters
        '*:*' + super
      end

      def complete_entry_identifiers
        @complete_entry_identifiers ||=
          begin
            entry_ids ||= Bulkrax::Importer.find(importerexporter.export_source).entries.pluck(:id)
            complete_statuses ||= Bulkrax::Status.latest_by_statusable
                                                 .includes(:statusable)
                                                 .where('bulkrax_statuses.statusable_id IN (?) AND bulkrax_statuses.statusable_type = ? AND status_message = ?', entry_ids, 'Bulkrax::Entry', 'Complete')

            complete_statuses.map { |s| s.statusable&.identifier&.gsub(':', '\:') }
          end
      end

      def works_query_kwargs
        query_kwargs.merge(
          fq: [
            %(#{solr_name(work_identifier)}:("#{complete_entry_identifiers.join('" OR "')}")),
            "has_model_ssim:(#{Bulkrax.curation_concerns.join(' OR ')})"
          ],
          fl: 'id'
        )
      end

      def works_query
        extra_filters.to_s
      end

      def collections_query_kwargs
        query_kwargs.merge(
          fq: [
            %(#{solr_name(work_identifier)}:("#{complete_entry_identifiers.join('" OR "')}")),
            "has_model_ssim:Collection"
          ],
          fl: 'id'
        )
      end

      def collections_query
        "has_model_ssim:Collection #{extra_filters}"
      end

      # This is an exception; we don't know how many candidate file sets there might be.  So we will instead
      # make the query (assuming that there are {#complete_entry_identifiers}).
      #
      # @see Bulkrax::ParserExportRecordSet::Base#file_sets
      def file_sets
        @file_sets ||= ActiveFedora::SolrService.query(file_sets_query, **file_sets_query_kwargs)
      end

      def file_sets_query_kwargs
        query_kwargs.merge(
          fq: [
            %(#{solr_name(work_identifier)}:("#{complete_entry_identifiers.join('" OR "')}")),
            "has_model_ssim:#{Bulkrax.file_model_class}"
          ],
          fl: 'id'
        )
      end

      def file_sets_query
        extra_filters
      end
    end
  end
end
