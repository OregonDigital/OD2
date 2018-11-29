# Generated via
#  `rails generate hyrax:work Video`
module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::VideoFormBehavior
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.required_fields = [:title, :dcmi_type, :rights_statement]

    self.model_class = ::Video

    def primary_terms
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) + [:title, :rights_statement]
    end

    def secondary_terms
      []
    end
  end
end
