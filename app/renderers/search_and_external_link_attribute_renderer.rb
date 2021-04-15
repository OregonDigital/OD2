# frozen_string_literal:true

# Display config for image object
class SearchAndExternalLinkAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
  private

  def li_value(value)
    external_link = options[:links][value] unless options[:links].nil?

    links = Array(super(value))
    links << link_to('<i class="fa fa-info-circle"></i><span class="sr-only">learn more</span>'.html_safe, external_link, 'aria-label' => 'Open link in new window', class: 'btn', target: '_blank', title: 'learn more') unless external_link.nil?
    links.join('')
  end

  def search_field
    if Generic.controlled_property_labels.to_s.include? field.to_s
      field.to_s.gsub('_label', '').to_sym
    elsif field.to_s == 'copyright_combined_label'
      'copyright_combined_label'.to_sym
    else
      options.fetch(:search_field, field)
    end
  end
end
