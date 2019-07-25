# frozen_string_literal:true

# Display config for image object
class SearchAndExternalLinkAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
  private

  def li_value(value)
    external_link = options[:links][value] unless options[:links].nil?

    links = Array(super(value))
    links << link_to('<span class="glyphicon glyphicon-new-window"></span>'.html_safe, external_link, 'aria-label' => 'Open link in new window', class: 'btn', target: '_blank') unless external_link.nil?
    links.join('')
  end
end
