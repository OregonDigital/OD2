# frozen_string_literal: true

# reindexes chunks of uris
class ReindexChunkWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # rubocop:disable Metrics/MethodLength
  def perform(uris)
    counter = 0
    logger = Rails.logger

    logger.info "Reindexing #{uris.count} URIs"
    uris.each do |uri|
      work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: ActiveFedora::Base.uri_to_id(uri))
      logger.info "\t reindexing #{work.id}"
      Hyrax.index_adapter.save(resource: work)
      counter += 1
    # rubocop:disable Style/RescueStandardError
    rescue => e
      logger.info "Failed to reindex #{work.id}: #{e.message}"
      next
    end
    # rubocop:enable Style/RescueStandardError
    logger.info "Total indexed: #{counter}/#{uris.count}"
  end
  # rubocop:enable Metrics/MethodLength
end
