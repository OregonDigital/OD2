# frozen_string_literal: true

# ReindexWorker is an extremely basic worker for reindexing a single asset,
# meant to be used in batch reindex operations as a way to ensure one asset's
# failure to reindex doesn't stop the rest of the assets' reindex processes.
class ReindexWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # pids must be ordered with access control objects first, then the actual
  # asset, then its sub-objects (a.g., proxies, indirect containers, etc.)
  def perform(access_control_pids, asset_pid, contains_pids)
    access_control_pids.each do |pid|
      obj = ActiveFedora::Base.find(pid)
      obj.permissions.each(&:update_index)
      obj.update_index
    end

    a = ActiveFedora::Base.find(asset_pid)
    a.update_index

    contains_pids.each { |pid| ActiveFedora::Base.find(pid).update_index }

    FetchGraphWorker.perform_async(asset_pid, a.depositor) if a.respond_to?(:depositor)
  end
end
