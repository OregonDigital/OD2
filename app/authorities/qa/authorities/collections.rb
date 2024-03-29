# frozen_string_literal: true

module Qa::Authorities
  # QA Authority for searching collections. Typically used for adding a work to a collection
  class Collections < Qa::Authorities::Base
    class_attribute :search_builder_class
    self.search_builder_class = Hyrax::CollectionSearchBuilder

    def search(_q, controller)
      # The Hyrax::CollectionSearchBuilder expects a current_user
      return [] unless controller.current_user

      response, _docs = search_response(controller)
      docs = response.documents
      docs.map do |doc|
        id = doc.id
        title = doc.title
        { id: id, label: title, value: id }
      end
    end

    private

    def search_service(controller)
      @search_service ||= Hyrax::SearchService.new(
        config: controller.blacklight_config,
        user_params: controller.params,
        search_builder_class: search_builder_class,
        scope: controller,
        current_ability: controller.current_ability
      )
    end

    # OVERRIDE FROM HYRAX: Append wildcard (*) to end of search query
    def search_response(controller)
      access = controller.params[:access] || 'read'

      search_service(controller).search_results do |builder|
        builder.where("#{controller.params[:q]}*")
               .with_access(access)
               .rows(100)
      end
    end
  end
end
