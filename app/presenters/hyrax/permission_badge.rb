module Hyrax
  class PermissionBadge
    include ActionView::Helpers::TagHelper

    VISIBILITY_LABEL_CLASS = {
      authenticated: "label-info",
      embargo: "label-warning",
      osu: "label-warning",
      uo: "label-warning",
      lease: "label-warning",
      open: "label-success",
      restricted: "label-danger"
    }.freeze

    # @param visibility [String] the current visibility
    def initialize(visibility)
      Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      Rails.logger.info visibility
      @visibility = visibility
    end

    # Draws a span tag with styles for a bootstrap label
    def render
      content_tag(:span, text, class: "label #{dom_label_class}")
    end

    private

      def dom_label_class
        VISIBILITY_LABEL_CLASS.fetch(@visibility.to_sym)
      end

      def text
        if registered?
          Institution.name
        else
          Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          Rails.logger.info @visibility
          I18n.t("hyrax.visibility.#{@visibility}.text")
        end
      end

      def registered?
        @visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      end
  end
end