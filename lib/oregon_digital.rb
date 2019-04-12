# frozen_string_literal: true

require 'oregon_digital/version'

# Sets logger for application
module OregonDigital
  extend ActiveSupport::Autoload

  # A hook to tie in rails default logger along with any improvements
  def self.logger
    @logger ||= Rails.logger
  end

  eager_autoload do
    autoload :ControlledVocabularies
    autoload :Derivatives
    autoload :Triplestore
    autoload :FeatureClassUriToLabel
  end
end
