# frozen_string_literal: true

# Sidekiq Worker for fetching linked data labels
class FetchGraphWorker
  include Sidekiq::Worker
  attr_writer :triplestore
  attr_accessor :uri, :user

  def perform(uri, user)
    @uri = uri
    @user = User.find_by_user_key(user)

    # Remove and save initial graph
    graph = delete_old_graph
    begin
      # Attempt fresh fetch
      triplestore.fetch(@uri, from_remote: true)
    rescue TriplestoreAdapter::TriplestoreException => e
      # Restore initial graph and retry later
      triplestore.store(graph)
      raise e
    end

    # Email user on success
    Hyrax.config.callback.run(:ld_fetch_success, @user, @uri)
  end

  def triplestore
    @triplestore ||= TriplestoreAdapter::Triplestore.new(OregonDigital::Triplestore.triplestore_client)
  end

  def delete_old_graph
    graph = triplestore.fetch(@uri)
    triplestore.client.delete(graph)
    graph
  end

  sidekiq_retries_exhausted do
    # Email user about exhaustion of retries
    Hyrax.config.callback.run(:ld_fetch_exhaust, @user, @uri)
  end
end
