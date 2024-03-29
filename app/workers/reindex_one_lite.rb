# frozen_string_literal: true

# ReindexOneLite is a small worker to reindex an existing work.
# Uses 'reindex' queue.
# For more thorough reindexing use ReindexWorker
class ReindexOneLite
  include Sidekiq::Worker
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # A single pid is expected
  def perform(pid)
    w = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid, use_valkyrie: false)
    w.update_index
    # Enable once all model objects are fully valkyrized and indexing works again
    # Hyrax.index_adapter.save(resource: w)
  end
end
