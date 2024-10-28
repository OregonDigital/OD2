# frozen_string_literal: true

module Bulkrax
  module ParserExportRecordSet
    # add additional way to filter works
    class LocalCollection < Base
      def works_query
        "local_collection_name_sim:\"#{importerexporter.export_source}\" #{extra_filters}"
      end

      def collections_query
        nil
      end
    end
  end
end
