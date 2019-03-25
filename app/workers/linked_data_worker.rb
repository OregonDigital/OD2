# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class LinkedDataWorker
  include Sidekiq::Worker
  attr_writer :triplestore
  attr_accessor :uri, :user

  def perform(uri, user)
    @uri = uri
    @user = user
    triplestore.fetch(uri, from_remote: true)
    # TODO: Email user on success
    Hyrax.config.callback.run(:ld_fetch_success, @user, @uri)
  end

  def triplestore
    @triplestore ||= TriplestoreAdapter::Triplestore.new(OregonDigital::Triplestore.triplestore_client)
  end

  sidekiq_retries_exhausted do |msg, ex|
    # TODO: Email user about death of retries
    Hyrax.config.callback.run(:ld_fetch_exhaust, @user, @uri)
  end
end
