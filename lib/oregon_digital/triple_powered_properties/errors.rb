# frozen_string_literal:true

module OregonDigital::TriplePoweredProperties
  # Sets errors for linked data objects
  module Errors
    ##
    # Base error
    class TriplePoweredPropertyError < StandardError
    end

    ##
    # Invalid URL
    class InvalidUrlError < TriplePoweredPropertyError
    end
  end
end
