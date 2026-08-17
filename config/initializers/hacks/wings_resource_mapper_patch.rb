# frozen_string_literal:true

Rails.application.config.to_prepare do
  Wings::ResourceMapper.class_eval do
    ##
    # Valkyrie objects contain a URI string for location objects so we need
    # to return just the string for mapping from Fedora
    # OVERRIDE FROM HYRAX/WINGS: We're not doing that remapping
    #
    # @return [RDF::Term || String]
    def result
      value.to_term
    end
  end
end