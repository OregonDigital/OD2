class OembedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
    def attribute_value_to_html(value)
      html = ""
      resource = OEmbed::Providers.get(value)
      html << resource.html
      return html
    end
end
