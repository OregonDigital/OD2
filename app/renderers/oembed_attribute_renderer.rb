class OembedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
    def attribute_value_to_html(value)
      html = "<div class='oembed-widget>'"
      html << content_tag(:div, "", data: { embed_url: Blacklight::Oembed::Engine.routes.url_helpers.embed_path(url: value) })
      html << "</div>"
      return html
    end
end
