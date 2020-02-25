# frozen_string_literal: true

module OregonDigital
  # A common base class for all OregonDigital jobs.
  # This allows downstream applications to manipulate all the OregonDigital jobs by
  # including modules on this class.
  class ApplicationJob < ActiveJob::Base
  end
end
