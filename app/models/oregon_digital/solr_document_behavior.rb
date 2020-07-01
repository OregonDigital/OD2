# frozen_string_literal:true

module OregonDigital
  # Custom SolrDocument behaviors
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    # OVERRIDE FROM HYRAX: to simplify visibility getter
    def visibility
      @visibility ||= self['visibility_ssi']
      @visibility ||= 'restricted'
    end
  end
end
