# frozen_string_literal:true

module Hyrax
  # Generated form for Generic
  class GenericForm < Hyrax::Forms::WorkForm
    self.model_class = ::Generic
    self.terms += (Generic.generic_properties.map(&:to_sym) + Generic.controlled_properties).sort
    self.terms += %i[date_uploaded]
    self.terms -= %i[based_near]
    self.terms = self.terms.uniq

    self.required_fields = %i[title resource_type rights_statement identifier]

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + (self.terms - required_fields) -
        %i[files visibility_during_embargo embargo_release_date
           visibility_after_embargo visibility_during_lease
           lease_expiration_date visibility_after_lease visibility
           thumbnail_id related_url representative_id rendering_ids ordered_member_ids
           member_of_collection_ids in_works_ids admin_set_id]
    end

    def secondary_terms
      []
    end

    # OVERRIDE: update initialize_field to initialize linked key property when blank
    def initialize_field(key)
      return if %i[embargo_release_date lease_expiration_date].include?(key)

      # rubocop:disable Lint/AssignmentInCondition
      if class_name = model_class.properties[key.to_s].try(:class_name)
        # Initialize linked properties such as based_near
        self[key] = [] if self[key].blank?
        self[key] += [class_name.new]
      else
        super
      end
      # rubocop:enable Lint/AssignmentInCondition
    end

    def self.build_permitted_params
      params = super
      Generic.controlled_property_labels.each do |prop|
        params << { prop.gsub('_label', '_attributes') => %i[id _destroy] }
      end
      params << :license
      params
    end
  end
end
