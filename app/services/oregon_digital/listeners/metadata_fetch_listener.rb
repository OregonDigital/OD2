# frozen_string_literal: true

module OregonDigital
  module Listeners
    # Listens for metadata update events and enqueues metadata fetch jobs
    class MetadataFetchListener
      ##
      # @param event [Dry::Event]
      def on_object_metadata_updated(event)
        FetchGraphWorker.perform_at(2.seconds, event[:object].id, event[:object].depositor)
      end
    end
  end
end
