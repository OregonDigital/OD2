# frozen_string_literal: true

module Hyrax
  module Renderers
    # Renders faceted attributes
    class FacetedAttributeRenderer < AttributeRenderer
      private

      def li_value(value)
	helpers.label_tag do
          '<span class="sr-only">Search Oregon Digital for</span>'.html_safe
          link_to(ERB::Util.h(value), search_path(value))
	end
      end

      def search_path(value)
        Rails.application.routes.url_helpers.search_catalog_path("f[#{search_field}][]": value, locale: I18n.locale)
      end

      def search_field
        ERB::Util.h(options.fetch(:search_field, field).to_s + '_sim')
      end
    end
  end
end
