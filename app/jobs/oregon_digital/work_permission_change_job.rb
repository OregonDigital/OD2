# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to activity streams
  class WorkPermissionChangeJob < ContentEventJob
    def action
      "User #{link_to_profile depositor} has updated permission of #{link_to repo_object.title.first, polymorphic_path(repo_object)} to #{visibility_badge(repo_object.visibility)}"
    end
  end
end
