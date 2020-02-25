Hyrax.config.callback.set(:after_create_concern) do |curation_concern, user|
  FetchGraphWorker.perform_in(1.minute, curation_concern.id, curation_concern.depositor)
  ContentDepositEventJob.perform_later(curation_concern, user)
end

Hyrax.config.callback.set(:after_update_metadata) do |curation_concern, user|
  FetchGraphWorker.perform_in(1.minute, curation_concern.id, curation_concern.depositor)
  ContentUpdateEventJob.perform_later(curation_concern, user)
end