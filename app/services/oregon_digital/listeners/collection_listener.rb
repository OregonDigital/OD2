# frozen_string_literal:true

module OregonDigital
  module Listeners
    # Listens for published collection events
    class CollectionListener
      # currently, collections do not have global id, and therefore cannot be passed to jobs
      def on_collection_metadata_updated(event)
        CollectionUpdateEventJob.perform_later(event[:collection].id, event[:user])
      end

      def on_collection_metadata_created(event)
        CollectionCreateEventJob.perform_later(event[:collection].id, event[:user])
      end
    end
  end
end
