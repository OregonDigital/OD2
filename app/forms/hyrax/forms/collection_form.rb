module Hyrax
  module Forms
    # rubocop:disable Metrics/ClassLength
    class CollectionForm
      include HydraEditor::Form
      include HydraEditor::Form::Permissions
      # Used by the search builder
      attr_reader :scope

      delegate :id, :depositor, :permissions, :human_readable_type, :member_ids, :nestable?, :alternative, to: :model

      class_attribute :membership_service_class

      # Required for search builder (FIXME)
      alias collection model

      self.model_class = ::Collection

      self.membership_service_class = Collections::CollectionMemberService

      delegate :blacklight_config, to: Hyrax::CollectionsController

      self.terms = [:alternative, :resource_type, :title, :creator, :contributor, :description,
                    :keyword, :license, :publisher, :date_created, :subject, :language,
                    :representative_id, :thumbnail_id, :identifier,
                    :related_url, :visibility, :collection_type_gid]

      self.required_fields = [:title]

      ProxyScope = Struct.new(:current_ability, :repository, :blacklight_config) do
        def can?(*args)
          current_ability.can?(*args)
        end
      end

      # @param model [Collection] the collection model that backs this form
      # @param current_ability [Ability] the capabilities of the current user
      # @param repository [Blacklight::Solr::Repository] the solr repository
      def initialize(model, current_ability, repository)
        super(model)
        @scope = ProxyScope.new(current_ability, repository, blacklight_config)
      end

      # Cast back to multi-value when saving
      # Reads from form
      def self.model_attributes(attributes)
        attrs = super
        return attrs unless attributes[:title]

        attrs[:title] = Array(attributes[:title])
        return attrs if attributes[:alternative].nil?
        Array(attributes[:alternative]).each do |value|
          attrs["title"] << value if value != ""
        end
        attrs
      end

      # @param [Symbol] key the field to read
      # @return the value of the form field.
      # For display in edit page
      def [](key)
        return model.member_of_collection_ids if key == :member_of_collection_ids
        if key == :title
          @attributes["title"].each do |value|
            @attributes["alternative"] << value
          end
          @attributes["alternative"].delete(@attributes["alternative"].sort.first) unless @attributes["alternative"].empty?
          return @attributes["title"].sort.first unless @attributes["title"].empty?
          return ""
        end
        super
      end

      def permission_template
        @permission_template ||= begin
                                   template_model = PermissionTemplate.find_or_create_by(source_id: model.id)
                                   PermissionTemplateForm.new(template_model)
                                 end
      end

      # @return [Hash] All FileSets in the collection, file.to_s is the key, file.id is the value
      def select_files
        Hash[all_files_with_access]
      end

      # Terms that appear above the accordion
      def primary_terms
        [:title, :description]
      end

      # Terms that appear within the accordion
      def secondary_terms
        [:alternative,
         :creator,
         :contributor,
         :keyword,
         :license,
         :publisher,
         :date_created,
         :subject,
         :language,
         :identifier,
         :related_url,
         :resource_type]
      end

      def banner_info
        @banner_info ||= begin
          # Find Banner filename
          banner_info = CollectionBrandingInfo.where(collection_id: id).where(role: "banner")
          banner_file = File.split(banner_info.first.local_path).last unless banner_info.empty?
          file_location = banner_info.first.local_path unless banner_info.empty?
          relative_path = "/" + banner_info.first.local_path.split("/")[-4..-1].join("/") unless banner_info.empty?
          { file: banner_file, full_path: file_location, relative_path: relative_path }
        end
      end

      def logo_info
        @logo_info ||= begin
          # Find Logo filename, alttext, linktext
          logos_info = CollectionBrandingInfo.where(collection_id: id).where(role: "logo")
          logos_info.map do |logo_info|
            logo_file = File.split(logo_info.local_path).last
            relative_path = "/" + logo_info.local_path.split("/")[-4..-1].join("/")
            alttext = logo_info.alt_text
            linkurl = logo_info.target_url
            { file: logo_file, full_path: logo_info.local_path, relative_path: relative_path, alttext: alttext, linkurl: linkurl }
          end
        end
      end

      # Do not display additional fields if there are no secondary terms
      # @return [Boolean] display additional fields on the form?
      def display_additional_fields?
        secondary_terms.any?
      end

      def thumbnail_title
        return unless model.thumbnail
        model.thumbnail.title.first
      end

      def list_parent_collections
        collection.member_of_collections
      end

      def list_child_collections
        collection_member_service.available_member_subcollections.documents
      end

      def available_parent_collections(scope:)
        return @available_parents if @available_parents.present?

        collection = Collection.find(id)
        colls = Hyrax::Collections::NestedCollectionQueryService.available_parent_collections(child: collection, scope: scope, limit_to_id: nil)
        @available_parents = colls.map do |col|
          { "id" => col.id, "title_first" => col.title.first }
        end
        @available_parents.to_json
      end

      private

        def all_files_with_access
          member_presenters(member_work_ids).flat_map(&:file_set_presenters).map { |x| [x.to_s, x.id] }
        end

        # Override this method if you have a different way of getting the member's ids
        def member_work_ids
          response = collection_member_service.available_member_work_ids.response
          response.fetch('docs').map { |doc| doc['id'] }
        end

        def collection_member_service
          @collection_member_service ||= membership_service_class.new(scope: scope, collection: collection, params: blacklight_config.default_solr_params)
        end

        def member_presenters(member_ids)
          PresenterFactory.build_for(ids: member_ids,
                                     presenter_class: WorkShowPresenter,
                                     presenter_args: [nil])
        end
    end
    # rubocop:enable ClassLength
  end
end
