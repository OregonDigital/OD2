# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to each fileset's activity streams
  class PermissionChangePropagationJob < Hyrax::ApplicationJob
    def perform(work)
      # Tried updating to valkyrie style, needs tested
      Hyrax.custom_queries.find_child_filesets(resource: work, use_valkyrie: false).each do |file_set|
        OregonDigital::PermissionChangePropagationEventJob.perform_later(file_set, nil)
      end
    end
  end
end
