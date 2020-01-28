# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchFailedGraphWorker
  include Sidekiq::Worker
  sidekiq_options retry: 11 # Around 2.5 days of retries

  attr_writer :triplestore
  attr_accessor :uri, :user

  def perform(uri, user)
    @uri = uri
    @user = User.find_by_user_key(user)

    # Exit early and skip notifying user if graph is already local
    return if triplestore.fetch(@uri)

    # Attempt fresh fetch and raise exception if failed again
    triplestore.fetch(@uri, from_remote: true)

    # Email user on success
    Hyrax.config.callback.run(:ld_fetch_success, @user, @uri)
  end

  def triplestore
    @triplestore ||= TriplestoreAdapter::Triplestore.new(OregonDigital::Triplestore.triplestore_client)
  end

  sidekiq_retries_exhausted do
    # Email user about exhaustion of retries
    Hyrax.config.callback.run(:ld_fetch_exhaust, @user, @uri)
  end
end
