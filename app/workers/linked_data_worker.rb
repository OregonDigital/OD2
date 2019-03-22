class LinkedDataWorker
  include Sidekiq::Worker

  def perform(uri)
      @triplestore ||= TriplestoreAdapter::Triplestore.new(OregonDigital::Triplestore.triplestore_client)
      @triplestore.fetch(uri, from_remote: true)
      # TODO: Email user on success
  end
end
