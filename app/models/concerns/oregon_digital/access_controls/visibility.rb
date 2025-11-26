# frozen_string_literal:true

module OregonDigital::AccessControls
  # Visibility Concern
  module Visibility
    extend ActiveSupport::Concern

    # THIS IS DISABLED DUE TO THE NEED OF ALL THE DIFFERENT POSSIBLE PERMISSION NEEDS
    # rubocop:disable Metrics/MethodLength
    def visibility=(value)
      case value
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        public_visibility!
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        registered_visibility!
      when OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_OSU
        osu_visibility!
      when OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_UO
        uo_visibility!
      when OregonDigital::AccessControls::AccessRight::ACCESSIBLE_TEXT_VALUE
        accessible_visibility!
      when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        private_visibility!
      else
        raise ArgumentError, "Invalid visibility: #{value.inspect}"
      end
    end

    def visibility
      if read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      elsif read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      elsif read_groups.include? OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_OSU
        OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_OSU
      elsif read_groups.include? OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_UO
        OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_UO
      elsif read_groups.include? OregonDigital::AccessControls::AccessRight::ACCESSIBLE_TEXT_VALUE
        OregonDigital::AccessControls::AccessRight::ACCESSIBLE_TEXT_VALUE
      else
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def represented_visibility
      [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED,
       Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC,
       OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_OSU,
       OregonDigital::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_UO,
       OregonDigital::AccessControls::AccessRight::ACCESSIBLE_TEXT_VALUE]
    end

    def osu_visibility!
      visibility_will_change! unless visibility == 'osu'
      remove_groups = represented_visibility - ['osu']
      set_read_groups(['osu'], remove_groups)
    end

    def uo_visibility!
      visibility_will_change! unless visibility == 'uo'
      remove_groups = represented_visibility - ['uo']
      set_read_groups(['uo'], remove_groups)
    end

    def accessible_visibility!
      visibility_will_change! unless visibility == 'accessible'
      remove_groups = represented_visibility - ['accessible']
      set_read_groups(['accessible'], remove_groups)
    end
  end
end
