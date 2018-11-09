# frozen_string_literal: true

require 'oregon_digital/version'

module OregonDigital
  extend ActiveSupport::Autoload

  ##
  # A hook to tie in rails default logger along with any improvements
  def self.logger
    @logger ||= Rails.logger
  end
end
