# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to each fileset's activity streams
  class RemoveFeaturedFileSetsJob < Hyrax::ApplicationJob
    def perform(work)
      work.file_set_ids.each do |fs_id|
        CollectionRepresentative.where(fileset_id: fs_id).each { |c| c.destroy }
      end
    end
  end
end
