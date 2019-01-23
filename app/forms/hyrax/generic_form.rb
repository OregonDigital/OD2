# frozen_string_literal:true

module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    include ::OregonDigital::TriplePoweredProperties::TriplePoweredForm

    self.model_class = ::Generic
    self.terms += OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)
    self.terms = self.terms.uniq

    self.required_fields = %i[title resource_type rights_statement identifier]

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + (self.terms - required_fields) -
        %i[files visibility_during_embargo embargo_release_date
           visibility_after_embargo visibility_during_lease
           lease_expiration_date visibility_after_lease visibility
           thumbnail_id representative_id rendering_ids ordered_member_ids
           member_of_collection_ids in_works_ids admin_set_id]
    end

    def secondary_terms
      []
    end
  end
end
