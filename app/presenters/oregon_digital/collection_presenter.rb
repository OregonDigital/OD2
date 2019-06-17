# frozen_string_literal: true

module OregonDigital
  # Override for collection presenter
  class CollectionPresenter < Hyrax::CollectionPresenter
    delegate :title, :description, :creator, :contributor, :subject, :publisher, :language, :embargo_release_date,
             :lease_expiration_date, :license, :date_created, :resource_type, :related_url, :identifier, :thumbnail_path,
             :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people,
             :institution, :date, :repository, to: :solr_document

    # Terms is the list of fields displayed by
    # app/views/collections/_show_descriptions.html.erb
    def self.terms
      %i[total_items size resource_type creator contributor license publisher date_created 
         subject language identifier related_url institution date repository]
    end
  end
end
