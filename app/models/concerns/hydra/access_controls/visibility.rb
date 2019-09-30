# frozen_string_literal:true

module Hydra::AccessControls
  # Visibility Concern
  module Visibility
    extend ActiveSupport::Concern

    # OVERRIDE FROM HYRAX: to add OSU & UO visbility setter options
    def visibility=(value)
      return if value.nil?

      # only set explicit permissions
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

    # OVERRIDE FROM HYRAX: to add OSU & UO visbility getter options
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

    # Override represented_visibility if you want to add another visibility that is
    # represented as a read group (e.g. on-campus)
    # @return [Array] a list of visibility types that are represented as read groups
    def represented_visibility
      [AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED,
       AccessRight::PERMISSION_TEXT_VALUE_PUBLIC,
       'osu',
       'uo']
    end

    def visibility_will_change!
      @visibility_will_change = true
    end

    def public_visibility!
      visibility_will_change! unless visibility == AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      remove_groups = represented_visibility - [AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
      set_read_groups([AccessRight::PERMISSION_TEXT_VALUE_PUBLIC], remove_groups)
    end

    def registered_visibility!
      visibility_will_change! unless visibility == AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      remove_groups = represented_visibility - [AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED]
      set_read_groups([AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED], remove_groups)
    end

    # OVERRIDE FROM HYRAX: to add OSU visbility setter method
    def osu_visibility!
      visibility_will_change! unless visibility == 'osu'
      remove_groups = represented_visibility - ['osu']
      set_read_groups(['osu'], remove_groups)
    end

    # OVERRIDE FROM HYRAX: to add UO visbility setter method
    def uo_visibility!
      visibility_will_change! unless visibility == 'uo'
      remove_groups = represented_visibility - ['uo']
      set_read_groups(['uo'], remove_groups)
    end

    def private_visibility!
      visibility_will_change! unless visibility == AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      set_read_groups([], represented_visibility)
    end
  end
end
