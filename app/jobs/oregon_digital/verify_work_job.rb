# frozen_string_literal: true

module OregonDigital
  ##
  # The job responsible for initiating verifying a work
  class VerifyWorkJob < ApplicationJob
    def perform(args)
      service = OregonDigital::VerifyWorkService.new(args)
      service.run
    end
  end
end
