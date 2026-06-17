# frozen_string_literal:true

# Similar to work event jobs except collections cannot be passed in
class CollectionEventJob < Hyrax::EventJob
  attr_reader :collection
  def perform(collid, depositor)
    @collection = Collection.find(collid)
    super(depositor)
    log_event(collection)
  end

  # Log the event to the object's stream
  def log_event(collection)
    collection.log_event(event)
  end

  # log the event to the users profile stream
  def log_user_event(depositor)
    depositor.log_profile_event(event)
  end
end
