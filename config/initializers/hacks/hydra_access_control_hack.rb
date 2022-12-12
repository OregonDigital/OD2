# frozen_string_literal: true

Rails.application.config.to_prepare do
  Hydra::AccessControl.class_eval do
    def permissions_attributes=(attribute_list)
      raise ArgumentError unless attribute_list.is_a? Array
      any_destroyed = false
      attribute_list.each do |attributes|
        if attributes.key?(:id)
          obj = relationship.find(attributes[:id])
          if has_destroy_flag?(attributes)
            obj.destroy
            any_destroyed = true
          else
            obj.update(attributes.except(:id, '_destroy'))
          # OVERRIDE from Hydra to prevent attempt to delete or update if relation does not exist
          end unless obj.blank?
        else
          relationship.build(attributes)
        end
      end
      # Poison the cache
      save! && relationship.reset if any_destroyed
    end
  end
end
