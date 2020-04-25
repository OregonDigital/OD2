# frozen_string_literal: true

module OregonDigital
  module Forms
    # Collection Form Override
    # Disabling because trying to fix Hyrax's broken code isn't worth the time.
    # rubocop:disable Metrics/AbcSize
    class CollectionForm < Hyrax::Forms::CollectionForm
      self.terms = %i[resource_type title creator contributor description license publisher
                      date_created subject language representative_id thumbnail_id
                      related_url visibility collection_type_gid institution date repository]

      def initialize_field(key)
        return if %i[embargo_release_date lease_expiration_date].include?(key)

        # rubocop:disable Lint/AssignmentInCondition
        if class_name = model_class.properties[key.to_s].try(:class_name)
          # Initialize linked properties such as based_near
          self[key] += [class_name.new]
        else
          super
        end
        # rubocop:enable Lint/AssignmentInCondition
      end

      def [](key)
        return model.member_of_collection_ids if key == :member_of_collection_ids

        if key == :title
          @attributes['title'].each do |value|
            @attributes['alt_title'] << value
          end
          @attributes['alt_title'].delete(@attributes['alt_title'].min) unless @attributes['alt_title'].empty?
          return @attributes['title'].sort unless @attributes['title'].empty?

          return ['']

        end
        super
      end

      def primary_terms
        %i[title description
           creator contributor
           license publisher
           date_created subject
           language
           related_url resource_type
           institution date
           repository]
      end

      def user_primary_terms
        %i[title description]
      end

      def secondary_terms
        []
      end

      def self.build_permitted_params
        params = super
        %w[creator contributor institution repository publisher subject].each do |prop|
          params << { "#{prop}_attributes" => %i[id _destroy] }
        end
        params << :license
        params
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
