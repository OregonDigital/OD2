# frozen_string_literal: true

#
# Helper job to bulk grant edit permissions for a user group (role).

module OregonDigital
  # Grant edit to user group
  class GrantEditGroupJob < Hyrax::ApplicationJob
    include Hyrax::MembersPermissionJobBehavior
    queue_as :default

    def perform(pid, group_key)
      r = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid) # Getting a valk resource
      r.permission_manager.edit_groups += [group_key] # Add group
      r.permission_manager.acl.save # Save permissions changes

      file_set_ids(r).each do |file_set_id|
        file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: file_set_id)
        file_set.permission_manager.edit_groups += [group_key]
        file_set.permission_manager.acl.save
      end
    end
  end
end
