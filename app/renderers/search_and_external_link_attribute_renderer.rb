# frozen_string_literal:true

# Display config for image object
class SearchAndExternalLinkAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
  private

  def li_value(value)
    return super(value) unless (uris = options[:links])

    links = []
    links << link_to(value, search_path(value))
    links << link_to('<span class="glyphicon glyphicon-new-window"></span>'.html_safe, uris[value], 'aria-label' => 'Open link in new window', class: 'btn', target: '_blank')
    links.join('')
  end
end
