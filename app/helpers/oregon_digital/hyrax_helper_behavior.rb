# frozen_string_literal:true

# Behaviors to add to Hyrax's helper
module OregonDigital::HyraxHelperBehavior
  # This helper is based on ifonify_auto_link in hyrax:
  # see hyrax/app/helpers/hyrax/hyrax_helper_behavior.rb
  # This extends iconify_auto_link to include highlight tokens given in em tags and
  # combines them with links. If hits are not found, it just returns the
  # linked text as usual.
  def iconify_auto_link_with_highlight(field, show_link = true)
    # get text from field
    if field.is_a? Hash
      options = field[:config].separator_options || {}
      text = field[:value].to_sentence(options)
    else
      text = field
    end

    # parse html to retrieve em tags (used for highlighed hits)
    html_content = Nokogiri::HTML.parse text

    sanitize combine_hits_with_links(html_content, show_link)
  end

  def collection_title_from_id(field, _show_link = true)
    SolrDocument.find(field).title_or_label
  end

  # @return [String] the appropriate action url for our search form (depending on our current page)
  def search_form_action
    anchor = '#content'
    if on_the_dashboard?
      search_action_for_dashboard + anchor
    else
      main_app.search_catalog_path + anchor
    end
  end

  private

  def combine_hits_with_links(html_content, show_link)
    # add links if any
    linked_text = auto_link(html_escape(html_content.text)) do |value|
      "<span class='glyphicon glyphicon-new-window'></span>#{('&nbsp;' + value) if show_link}"
    end

    # decode em tags (hits) and return linked text, including hits
    html_content.css('em').children.each do |hit|
      linked_text = linked_text.gsub(hit, tag.em(hit))
    end
    linked_text
  end
end
