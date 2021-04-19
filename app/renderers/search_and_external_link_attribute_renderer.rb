# frozen_string_literal:true

# Display config for image object
class SearchAndExternalLinkAttributeRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  private

  def li_value(value)
    external_link = options[:links][value] unless options[:links].nil?

    links = Array(super(value))
    links << link_to('<i class="fa fa-info-circle"></i><span class="sr-only">learn more</span>'.html_safe, external_link, 'aria-label' => 'Open link in new window', class: 'btn', target: '_blank', title: 'learn more') unless external_link.nil?
    links.join('')
  end
end
