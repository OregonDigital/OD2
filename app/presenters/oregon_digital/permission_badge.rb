# frozen_string_literal:true

module OregonDigital
  # PermissionBadge Presenter
  class PermissionBadge < Hyrax::PermissionBadge
    include ActionView::Helpers::TagHelper

    VISIBILITY_LABEL_CLASS = {
      authenticated: 'badge-info',
      embargo: 'badge-warning',
      osu: 'badge-warning',
      uo: 'badge-warning',
      lease: 'badge-warning',
      open: 'badge-success',
      restricted: 'badge-danger'
    }.freeze

    private

    def dom_label_class
      VISIBILITY_LABEL_CLASS.fetch(@visibility.to_sym)
    end
  end
end
