# frozen_string_literal:true

module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    self.model_class = ::Generic
    self.terms += (Generic.generic_properties.map(&:to_sym) + Generic.controlled_properties).sort + %i[date_uploaded date_modified]
    self.terms -= %i[based_near]
    self.terms = self.terms.uniq
    self.required_fields = %i[title resource_type rights_statement identifier]

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields -
        %i[alternative_title access_right rights_notes
           files visibility_during_embargo embargo_release_date
           visibility_after_embargo visibility_during_lease
           lease_expiration_date visibility_after_lease visibility
           thumbnail_id representative_id rendering_ids ordered_member_ids
           member_of_collection_ids in_works_ids admin_set_id]
    end

    def secondary_terms
      []
    end

    def [](key)
      return model.member_of_collection_ids if key == :member_of_collection_ids

      @attributes[key.to_s]
    end

    def solr_document
      @solr_document ||= ::SolrDocument.find(model.id)
    end

    def self.build_permitted_params
      params = super - %i[date_uploaded date_modified]
      Generic.controlled_property_labels.each do |prop|
        params << { prop.gsub('_label', '_attributes') => %i[id _destroy] }
      end
      params << %i[license mask_content]
      params
    end
  end
end
