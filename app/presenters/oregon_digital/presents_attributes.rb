# frozen_string_literal:true

module OregonDigital
  # OVERRIDE FOR PERMISSION BADGE
  module PresentsAttributes
    def permission_badge_class
      OregonDigital::PermissionBadge
    end
  end
end
