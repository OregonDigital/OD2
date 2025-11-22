# frozen_string_literal:true

module OregonDigital
  # PermissionBadge Presenter
  class PermissionBadge < Hyrax::PermissionBadge
    include ActionView::Helpers::TagHelper

    VISIBILITY_LABEL_CLASS = {
      authenticated: 'label-info',
      embargo: 'label-warning',
      osu: 'label-warning',
      uo: 'label-warning',
      lease: 'label-warning',
      open: 'label-success',
      restricted: 'label-danger',
      accessible: 'label-info'
    }.freeze

    private

    def dom_label_class
      VISIBILITY_LABEL_CLASS.fetch(@visibility.to_sym)
    end
  end
end
