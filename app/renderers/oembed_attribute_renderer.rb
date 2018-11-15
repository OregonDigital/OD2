class OembedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
    def attribute_value_to_html(value)
      html = ""
      begin
        resource = OEmbed::Providers.get(value)
        html << resource.html
      rescue OEmbed::NotFound => e
        html << "No embeddable content at '#{value}'"
      end
      return html
    end
end
