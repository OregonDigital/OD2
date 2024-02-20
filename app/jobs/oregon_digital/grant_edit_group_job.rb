# frozen_string_literal: true
#
# Helper job to bulk grant edit permissions for a user group (role).

module OregonDigital
  # Grant edit to user group
  class GrantEditGroupJob < Hyrax::ApplicationJob
    include Hyrax::MembersPermissionJobBehavior
    queue_as :default

    def perform(pid, group_key)
      w = ActiveFedora::Base.find(pid)
      w.edit_groups += [group_key]
      w.save

      # Also grant to filesets
      file_set_ids(w).each do |file_set_id|
        file_set = ::FileSet.find(file_set_id)
        file_set.edit_groups += [group_key]
        file_set.save!
      end
    end
  end
end
