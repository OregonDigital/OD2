# frozen_string_literal:true

# Display config for image object
class SearchAndExternalLinkAttributeRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  private

  def li_value(value)
    external_link = options[:links][value] unless options[:links].nil?

    links = Array(super(value))
    links << link_to("<sup>#{options[:index]}</sup>".html_safe, "##{options[:index]}", 'aria-label' => 'learn more about this taxonomy term', class: 'metadata-superscript', title: 'learn more')
    links.join('')
  end
end
