# frozen_string_literal: true

# ReindexWorker is an extremely basic worker for reindexing a single asset,
# meant to be used in batch reindex operations as a way to ensure one asset's
# failure to reindex doesn't stop the rest of the assets' reindex processes.
class ReindexWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # pids must be ordered with access control objects first, then the actual
  # asset, then its sub-objects (a.g., proxies, indirect containers, etc.)
  # rubocop:disable Metrics/AbcSize:
  # rubocop:disable Metrics/MethodLength:
  def perform(access_control_pids, asset_pid, contains_pids)
    access_control_pids.each do |pid|
      obj = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
      obj.permissions.each(&:update_index)
      Hyrax.index_adapter.save(resource: obj)
    end

    a = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: asset_pid)
    Hyrax.index_adapter.save(resource: a)

    contains_pids.each do |pid|
      obj = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
      Hyrax.index_adapter.save(resource: obj)
    end

    FetchGraphWorker.perform_async(asset_pid, a.depositor) if a.respond_to?(:depositor)
  end
  # rubocop:enable Metrics/MethodLength:
  # rubocop:enable Metrics/AbcSize:
end
