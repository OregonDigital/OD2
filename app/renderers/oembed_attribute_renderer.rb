# frozen_string_literal:true

class OembedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    div = content_tag(
      :div,
      '',
      data: {
        embed_url:
          Blacklight::Oembed::Engine.routes.url_helpers.embed_path(url: value)
      }
    )
    "<div class='oembed-widget'>#{div}</div>"
  end
end
