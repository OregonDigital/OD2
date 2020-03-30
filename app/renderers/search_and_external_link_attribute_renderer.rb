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

  def search_field
    search_link_field = if creator_fields.include? field.to_sym
                          :creator_combined_label
                        elsif scientific_fields.include? field.to_sym
                          :scientific_combined_label
                        elsif topic_fields.include? field.to_sym
                          :topic_combined_label
                        elsif location_fields.include? field.to_sym
                          :location_combined_label
                        else
                          options.fetch(:search_field, field)
                        end
  end

  def creator_fields
    %i[arranger_label artist_label author_label cartographer_label collector_label composer_label creator_label contributor_label dedicatee_label donor_label designer_label editor_label illustrator_label interviewee_label interviewer_label lyricist_label owner_label patron_label photographer_label print_maker_label recipient_label transcriber_label translator_label]
  end

  def topic_fields
    %i[keyword_label subject_label]
  end

  def location_fields
    %i[ranger_district_label water_basin_label location_label]
  end

  def scientific_fields
    %i[taxon_class_label family_label genus_label order_label species_label phylum_or_division_label]
  end
end
