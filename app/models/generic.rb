# frozen_string_literal:true

# Sets the expected behaviors of a generic work
class Generic < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::OregonDigital::WorkBehavior

  self.indexer = GenericIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validate :dates_edtf_format

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::GenericMetadata
  include ::OregonDigital::ControlledPropertiesBehavior

  private
    def dates_edtf_format
      edtf_fields.each do |field|
        send(field).each do |value|
          errors.add(field, "'#{value}' is not in EDTF format") unless EDTF.parse(value).present?
        end
      end
    end

    def edtf_fields
      %i[ date acquisition_date award_date collected_date issued view_date ]
    end
end
