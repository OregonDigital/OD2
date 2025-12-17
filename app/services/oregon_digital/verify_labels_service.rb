# frozen_string_literal:true

module OregonDigital
  # A service to verify that labels exist using the solr document
  class VerifyLabelsService < VerifyService
    attr_reader :verification_errors

    def verify
      @verification_errors = { labels: [] }
      properties.reject { |p| @work.send(p.to_sym).blank? }.each do |property|
        verify_labels(property)
      end
      @verification_errors
    end

    def properties
      OregonDigital::GenericMetadata::ORDERED_PROPERTIES.select { |x| x[:is_controlled] == true }.map { |x| x[:name].gsub('_label', '') }
    end

    def solr_parsable_labelize(field)
      "#{field}_parsable_label_ssim"
    end

    def verify_labels(property)
      missing = []
      vals = @solr_doc[solr_parsable_labelize(property)]
      return @verification_errors[:labels] << "#{property}: has no values}" if vals.blank?

      vals.each do |val|
        missing << val.gsub('$', '') if val.start_with?('$')
      end
      return if missing.empty?

      @verification_errors[:labels] << { property => missing }
    end
  end
end
