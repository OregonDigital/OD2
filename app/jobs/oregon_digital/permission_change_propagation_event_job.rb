# frozen_string_literal: true

module OregonDigital
  # Log content permissions update to activity streams
  class PermissionChangePropagationEventJob < EventJob
    attr_reader :repo_object, :repo_object_parent
    def perform(repo_object, repo_object_parent)
      @repo_object = repo_object
      @repo_object_parent = repo_object_parent
      log_event(repo_object)
    end

    def action
      "Permission has been updated to #{visibility_badge(repo_object.visibility)} when #{link_to repo_object_parent.title.first, polymorphic_path(repo_object_parent)} updated"
    end

    # Log the event to the object's stream
    def log_event(repo_object)
      repo_object.log_event(event)
    end

    # Pass logging to the users profile stream since we don't have a user
    def log_user_event(_depositor)
      nil
    end
  end
end
