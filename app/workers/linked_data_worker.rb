# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class LinkedDataWorker
  include Sidekiq::Worker
  attr_writer :triplestore

  def perform(uri)
    @triplestore.fetch(uri, from_remote: true)
    # TODO: Email user on success
  end

  def triplestore
    @triplestore ||= TriplestoreAdapter::Triplestore.new(OregonDigital::Triplestore.triplestore_client)
  end

  sidekiq_retries_exhausted do |msg, ex|
    # TODO: Email user about death of retries
  end
end
