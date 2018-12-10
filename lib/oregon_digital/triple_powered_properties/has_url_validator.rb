# frozen_string_literal:true

require 'uri'

module OregonDigital::TriplePoweredProperties
  class HasUrlValidator < ActiveModel::Validator
    ##
    # Evaluate each triple powered property value to ensure it is a valid URL
    #
    # @param record [ActiveModel] the model being validated
    def validate(record)
      return if record.triple_powered_properties.empty?

      record.triple_powered_properties.each do |prop|
        record[prop].each do |value|
          URI.parse(value)
        rescue URI::InvalidURIError
          record.errors[prop] << "#{value} is invalid"
        rescue StandardError
          record.errors[prop] << "#{value} is not a URL"
        end
      end
    end
  end
end
