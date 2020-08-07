# Hyrax.publisher.subscribe(OregonDigital::Listeners::MetadataFetchListener.new)

Hyrax.config.callback.set(:after_create_concern) do |curation_concern, user|
  ContentDepositEventJob.perform_later(curation_concern, user)
  FetchGraphWorker.perform_async(curation_concern.id, curation_concern.depositor)
end

Hyrax.config.callback.set(:after_update_metadata) do |curation_concern, user|
  ContentUpdateEventJob.perform_later(curation_concern, user)
  FetchGraphWorker.perform_async(curation_concern.id, curation_concern.depositor)
end