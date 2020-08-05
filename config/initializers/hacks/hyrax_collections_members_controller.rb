# frozen_string_literal:true

Hyrax::Dashboard::CollectionMembersController.class_eval do
  # Override after update method to redirect users back to where they updated the collection from
  def after_update;end

  def update_members
    err_msg = validate
    after_update_error(err_msg) if err_msg.present?
    return if err_msg.present?

    collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    members = collection.add_member_objects batch_ids
    messages = members.collect { |member| member.errors.full_messages }.flatten
    if messages.size == members.size
      after_update_error(messages.uniq.join(', '))
    elsif messages.present?
      flash[:error] = messages.uniq.join(', ')
      after_update
    else
      members.each { |member| Hyrax.config.callback.run(:after_update_metadata, member, current_user, warn: false) unless member.instance_of? Collection }
      after_update
    end
  end
end