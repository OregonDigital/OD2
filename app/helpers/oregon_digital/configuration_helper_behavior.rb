# frozen_string_literal:true

module OregonDigital::ConfigurationHelperBehavior
  ##
  # Look up the label for the facet field
  # OVERRIDE FROM BLACKLIGHT to reorder defaults
  def facet_field_label field
    field_config = blacklight_config.facet_fields[field]
    defaults = []
    defaults << field_config.label if field_config
    defaults << :"blacklight.search.fields.facet.#{field}"
    defaults << :"blacklight.search.fields.#{field}"
    defaults << field.to_s.humanize

    field_label(*defaults)
  end

  ##
  # Look up the label for a solr field.
  #
  # @overload label
  #   @param [Symbol] an i18n key
  #
  # @overload label, i18n_key, another_i18n_key, and_another_i18n_key
  #   @param [String] default label to display if the i18n look up fails
  #   @param [Symbol] i18n keys to attempt to look up
  #     before falling  back to the label
  #   @param [Symbol] any number of additional keys
  #   @param [Symbol] ...
  # OVERRIDE FROM BLACKLIGHT to display first if it's a string, otherwise i18n it
  def field_label *i18n_keys
    first, *rest = i18n_keys.compact

    if first.kind_of?(Symbol)
      t(first, default: rest)
    else
      first
    end
  end
end
