# frozen_string_literal:true

module OregonDigital
  # Validates EDTF format on a list of date fields
  module ValidatesEDTFBehavior
    extend ActiveSupport::Concern

    included do
      validate :dates_edtf_format
    end

    private

    def dates_edtf_format
      edtf_fields.each do |field|
        send(field).each do |value|
          unless EDTF.parse(value).present?
            errors.add(:base, 'EDTF format error')
            errors.add(field, "'#{value}' is not in EDTF format")
          end
        end
      end
    end

    def edtf_fields
      %i[date acquisition_date award_date collected_date issued view_date]
    end
  end
end
