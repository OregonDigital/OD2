# frozen_string_literal: true
module OregonDigital
  module Collections
    ##
    # Retrieves collection members
    class CollectionMemberService < Hyrax::Collections::CollectionMemberService
      ##
      # @api public
      #
      # Work ids of the works which are members of the given collection
      #
      # @return [Blacklight::Solr::Response]
      def available_member_work_ids
        response, _docs = search_results do |builder|
          builder.search_includes_models = :works
          builder.merge(fl: 'id', rows: 100_000)
          builder
        end
        response
      end
    end
  end
end
