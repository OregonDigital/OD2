class OembedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
    def attribute_value_to_html(value)
      resource = OEmbed::Providers.get(value)
      return resource.html
    end
end
