# frozen_string_literal:true

Rails.application.config.to_prepare do
  ActiveFedora::Indexing.module_eval do
    # OVERRIDE for locking on index update.
    # Updating the index can result in a race condition where one index instance cloberes another already running

    # Updates Solr index with self.
    def update_index
      if respond_to? :acquire_lock_for
        acquire_lock_for(self.id) do
          ActiveFedora::SolrService.add(to_solr, softCommit: true)
        end
      else
        ActiveFedora::SolrService.add(to_solr, softCommit: true)
      end
    end
  end
end
