# frozen_string_literal:true

module OregonDigital
  # Provide select options for the license (dcterms:rights) field
  class LanguageService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('languages')
    end
  end
end
