# frozen_string_literal: true

module OregonDigital::Jobs
  ##
  # The job responsible for initiating verifying a work
  class VerifyWorkJob < Hyrax::Migrator::ApplicationJob
    def perform(args)
      service = Hyrax::Migrator::Services::VerifyWorkService.new(args)
      service.run
    end
  end
end
