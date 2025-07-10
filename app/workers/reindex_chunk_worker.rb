# frozen_string_literal: true

# reindexes chunks of uris
class ReindexChunkWorker
  include Sidekiq::Worker
  include OregonDigital::TriplestoreHealth
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def perform(uris)
    raise OregonDigital::TriplestoreHealth::TriplestoreHealthError unless triplestore_is_alive?

    counter = 0

    logger.info "Reindexing #{uris.count} URIs"
    uris.each do |uri|
      work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: Hyrax.config.translate_uri_to_id.call(uri), use_valkyrie: false)
      logger.info "\t reindexing #{work.id}"
      work.update_index
      # Enable once all model objects are fully valkyrized and indexing works again
      # Hyrax.index_adapter.save(resource: work)
      counter += 1
    # rubocop:disable Style/RescueStandardError
    rescue => e
      logger.info "Failed to reindex #{work.id}: #{e.message}"
      next
    end
    # rubocop:enable Style/RescueStandardError
    logger.info "Total indexed: #{counter}/#{uris.count}"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
