# frozen_string_literal: true

# ReindexOneLite is a small worker to reindex an existing work.
# Uses 'reindex' queue.
# For more thorough reindexing use ReindexWorker
class ReindexOneLite
  include Sidekiq::Worker
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # A single pid is expected
  def perform(pid)
    w = ActiveFedora::Base.find(pid)
    w.update_index
  end
end
