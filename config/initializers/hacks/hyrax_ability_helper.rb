# frozen_string_literal:true

Rails.application.config.to_prepare do
  Hyrax::AbilityHelper.module_eval do
    # OVERRIDE for adding visibility options for badges
    def visibility_options(variant)
      options = [
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_OSU,
        OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_UO,
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      ]
      case variant
      when :restrict
        options.delete_at(0)
        options.reverse!
      when :loosen
        options.delete_at(3)
      end
      options.map { |value| [visibility_text(value), value] }
    end

    def visibility_badge(value)
      OregonDigital::PermissionBadge.new(value).render
    end
  end
end