# frozen_string_literal:true

class OembedAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  # TODO: Offload the loading of the OEmbed value to the client,
  # render only the link to client-side.
  def attribute_value_to_html(value)
    resource = OEmbed::Providers.get(value)
    resource.html
  rescue OEmbed::NotFound
    "No embeddable content at '#{value}'"
  end
end
