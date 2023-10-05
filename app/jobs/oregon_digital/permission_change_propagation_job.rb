# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to each fileset's activity streams
  class PermissionChangePropagationJob < Hyrax::ApplicationJob
    def perform(work)
      work.member_ids.map(&:id).map do |id|
        file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id)
        next unless file_set.file_set?

        OregonDigital::PermissionChangePropagationEventJob.perform_later(file_set, work)
      end
    end
  end
end
