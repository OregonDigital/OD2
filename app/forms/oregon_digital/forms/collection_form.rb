module OregonDigital
  module Forms
    class CollectionForm < Hyrax::Forms::CollectionForm
      self.terms = [:alternative, :resource_type, :title, :creator, :contributor, :description,
                    :license, :publisher, :date_created, :subject, :language,
                    :representative_id, :thumbnail_id, :identifier,
                    :related_url, :visibility, :collection_type_gid, :institution, :date, :repository]

      def initialize_field(key)
        return if [:embargo_release_date, :lease_expiration_date].include?(key)
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
          @attributes["title"].each do |value|
            @attributes["alternative"] << value
          end
          @attributes["alternative"].delete(@attributes["alternative"].sort.first) unless @attributes["alternative"].empty?
          return @attributes["title"].sort unless @attributes["title"].empty?
          return [""]
        end
        super
      end

      def primary_terms
        [:title, 
         :description, 
         :alternative,
         :creator,
         :contributor,
         :license,
         :publisher,
         :date_created,
         :subject,
         :language,
         :identifier,
         :related_url,
         :resource_type, 
         :institution, 
         :date, 
         :repository]
      end

      def secondary_terms
        []
      end
    end
  end
end