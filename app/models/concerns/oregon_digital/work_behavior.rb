# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets base behaviors for all works
  module WorkBehavior
    extend ActiveSupport::Concern
    include OregonDigital::AccessControls::Visibility
    include OregonDigital::MetadataDownload

    included do
      validates_presence_of %i[title resource_type rights_statement identifier]
    end

    def graph_fetch_failures
      @graph_fetch_failures ||= []
    end

    # Export work metadata as CSV string
    def csv_metadata(keys, controlled_keys)
      # Build a CSV of label headers and metadata value data
      ::CSV.generate do |csv|
        csv << keys
        csv << metadata_row(keys, controlled_keys)
        child_works.each do |work|
          csv << work.metadata_row(keys, controlled_keys)
        end
      end
    end
  end
end
