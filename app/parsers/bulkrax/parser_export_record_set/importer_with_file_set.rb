# frozen_string_literal: true

module Bulkrax
  module ParserExportRecordSet
    # enable bulkrax user to export associated file sets
    class ImporterWithFileSet < Importer
      # rubocop:disable Style/SymbolProc
      def candidate_file_set_ids
        @candidate_file_set_ids ||= work_docs.flat_map { |h| h['member_ids_ssim'] }.reject { |x| x.nil? }
      end
      # rubocop:enable Style/SymbolProc

      def work_ids
        @work_ids ||= work_docs.map { |h| h['id'] }
      end

      # splits out the querying part into work_docs below
      # i.e. this batches and grabs just the id field as in the original method
      def works
        @works ||= Bulkrax::ParserExportRecordSet.in_batches(work_docs) do |docs|
          docs.flat_map { |h| h['id'] }.map { |id| { 'id' => id } }
        end
      end

      # this is essentially the works method, but not batched, and
      # returning [{"id"=>"5q47rn72z", "member_ids_ssim"=>["f05q47rn72z"]}]
      # rather than just the work id
      def work_docs
        @work_docs ||= Bulkrax.object_factory.query(
          extra_filters.to_s,
          **query_kwargs.merge(
            fq: [
              %(#{solr_name(work_identifier)}:("#{complete_entry_identifiers.join('" OR "')}")),
              "has_model_ssim:(#{Bulkrax.curation_concern_internal_resources.join(' OR ')})"
            ]
          )
        )
      end

      # modified to use pids, NOT bulkrax entry identifiers
      # bc child filesets won't have them
      # rubocop:disable Metrics/MethodLength
      def file_sets
        @file_sets ||= Bulkrax::ParserExportRecordSet.in_batches(work_ids + candidate_file_set_ids) do |ids|
          Bulkrax.object_factory.query(
            extra_filters,
            **query_kwargs.merge(
              fq: [
                %(id:(#{ids.join(' OR ')})),
                "has_model_ssim:#{Bulkrax.file_model_internal_resource}"
              ],
              fl: 'id'
            )
          )
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
