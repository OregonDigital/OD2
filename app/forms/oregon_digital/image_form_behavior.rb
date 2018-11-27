module OregonDigital
  module ImageFormBehavior
    extend ActiveSupport::Concern
    included do
      self.terms += OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym)
    end
  end
end
