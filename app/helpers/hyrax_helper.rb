# frozen_string_literal:true

# Application wide helper to contain hyrax based methods
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

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

    # add links if any
    linked_text = auto_link(html_escape(html_content.text)) do |value|
      "<span class='glyphicon glyphicon-new-window'></span>#{('&nbsp;' + value) if show_link}"
    end

    # decode em tags (hits) and return linked text, including hits
    html_content.css('em').children.each do |hit|
      linked_text = linked_text.gsub(hit, tag.em(hit))
    end
    sanitize linked_text
  end
end
