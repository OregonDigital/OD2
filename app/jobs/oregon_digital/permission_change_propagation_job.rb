# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to each fileset's activity streams
  class PermissionChangePropagationJob < Hyrax::ApplicationJob
    def perform(work)
      work.member_ids.map(&:to_s).map do |id|
        file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id, use_valkyrie: false)
        next unless file_set.file_set?

        OregonDigital::PermissionChangePropagationEventJob.perform_later(file_set, work)
      end
    end
  end
end
