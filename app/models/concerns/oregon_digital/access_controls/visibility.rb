# frozen_string_literal:true

module OregonDigital::AccessControls
  # Visibility Concern
  module Visibility
    extend ActiveSupport::Concern

    def visibility=(value)
      return if value.nil?

      case value
      when AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        public_visibility!
      when AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        registered_visibility!
      when 'osu'
        osu_visibility!
      when 'uo'
        uo_visibility!
      when AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        private_visibility!
      else
        raise ArgumentError, "Invalid visibility: #{value.inspect}"
      end
    end

    def visibility
      if read_groups.include? AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
        AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      elsif read_groups.include? AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
        AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      elsif read_groups.include? 'osu'
        'osu'
      elsif read_groups.include? 'uo'
        'uo'
      else
        AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      end
    end

    def visibility_changed?
      !!@visibility_will_change
    end

    private

    def represented_visibility
      [AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED,
       AccessRight::PERMISSION_TEXT_VALUE_PUBLIC,
       'osu',
       'uo']
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
  end
end