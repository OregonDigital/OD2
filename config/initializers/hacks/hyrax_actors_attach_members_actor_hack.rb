Rails.application.config.to_prepare do
  Hyrax::Actors::AttachMembersActor.class_eval do
    attr_reader :env
    # @param [Hyrax::Actors::Environment] env
    # @return [Boolean] true if update was successful
    def update(env)
      @env = env
      attributes_collection = env.attributes.delete(:work_members_attributes)
      assign_nested_attributes_for_collection(env, attributes_collection) &&
        next_actor.update(env)
    end

    def update_members(resource:, inserts: [], destroys: [])
      resource.member_ids += inserts.map  { |id| Valkyrie::ID.new(id) }
      record_child_attach_event(resource: resource, inserts: inserts)
      resource.member_ids -= destroys.map { |id| Valkyrie::ID.new(id) }
      record_child_detach_event(resource: resource, destroys: destroys)
    end

    def record_child_attach_event(resource:, inserts: [])
      inserts.map { |id| AttachChildToWorkEventJob.perform_later(resource, id, @env.current_ability.current_user) }
    end

    def record_child_detach_event(resource:, destroys: [])
      destroys.map { |id| DetachChildFromWorkEventJob.perform_later(resource, id, @env.current_ability.current_user) }
    end
  end
end