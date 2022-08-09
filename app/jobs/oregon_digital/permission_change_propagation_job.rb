# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to each fileset's activity streams
  class PermissionChangePropagationJob < Hyrax::ApplicationJob
    def perform(work)
      # Tried updating to valkyrie style, needs tested
      work.file_sets.each do |file_set|
        OregonDigital::PermissionChangePropagationEventJob.perform_later(file_set, work)
      end
    end
  end
end
