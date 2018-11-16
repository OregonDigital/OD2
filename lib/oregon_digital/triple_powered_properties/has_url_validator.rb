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
          begin
            uri = URI.parse(value)
          rescue
            record.errors[prop] << "#{value} is not a URL"
          else
            record.errors[prop] << "#{value} is invalid" unless uri.kind_of?(URI::HTTP)
          end
        end
      end
    end
  end
end