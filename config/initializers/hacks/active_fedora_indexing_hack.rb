# frozen_string_literal:true

Rails.application.config.to_prepare do
  ActiveFedora::Indexing.module_eval do
    # OVERRIDE for locking on index update.
    # Updating the index can result in a race condition where one index instance cloberes another already running

    # Updates Solr index with self.
    def update_index
      Rails.logger.info "AFIndexing: Acquiring Lock"
      if respond_to? :acquire_lock_for
        acquire_lock_for(self.id) do
          Rails.logger.info "AFIndexing: Lock Acquired"
          ActiveFedora::SolrService.add(to_solr, softCommit: true)
        end
      else
        Rails.logger.info "AFIndexing: Index #{self.class} without lock"
        ActiveFedora::SolrService.add(to_solr, softCommit: true)
      end
      Rails.logger.info "AFIndexing: Lock Released"
    end
  end
end