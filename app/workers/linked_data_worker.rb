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
end
