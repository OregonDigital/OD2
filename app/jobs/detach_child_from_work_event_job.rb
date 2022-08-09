# frozen_string_literal: true

# Log child update to activity streams
# TODO: Get working & hooked up to child removal event
class DetachChildFromWorkEventJob < ContentEventJob
  attr_reader :parent_object, :child_object
  def perform(parent_object, child_id, depositor)
    # Get the parent/child as af resources
    @parent_object = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: parent_object.id, use_valkyrie: false)
    @child_object = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: child_id, use_valkyrie: false)
    super(@parent_object, depositor)
    log_event(@child_object)
  end

  def action
    "User #{link_to_profile depositor} has detached the child #{link_to child_object.title.first, polymorphic_path(child_object)} from #{link_to parent_object.title.first, polymorphic_path(parent_object)}"
  end
end
