# frozen_string_literal: true

module OregonDigital
  # Override for collection presenter
  class CollectionPresenter < Hyrax::CollectionPresenter
    include OregonDigital::PresentsAttributes
    delegate :title, :description, :creator, :contributor, :subject, :publisher, :language, :embargo_release_date,
             :lease_expiration_date, :license, :date_created, :resource_type, :related_url, :thumbnail_path,
             :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people,
             :institution, :date, :repository, to: :solr_document

    # Terms is the list of fields displayed by
    # app/views/collections/_show_descriptions.html.erb
    def self.terms
      %i[total_items size resource_type creator_label contributor_label license publisher_label date_created
         subject_label language related_url institution_label date repository_label]
    end
  end
end
