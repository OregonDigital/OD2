# frozen_string_literal:true

# Display config for image object
class SearchAndExternalLinkAttributeRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  private

  def li_value(value)
    links = Array(super(value))
    links << link_to("<sup>#{options[:indices][value]}</sup>".html_safe, '#data_sources', 'aria-label' => 'learn more about this taxonomy term', class: 'metadata-superscript', title: 'learn more') unless value.nil?
    links.join('')
  end
end
