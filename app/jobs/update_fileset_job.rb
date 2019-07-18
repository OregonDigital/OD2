# frozen_string_literal:true

# Loads a FileSet and reindexes for thumbnail and extracted text.  Meant to be
# queued up after derivative generation has completed successfully.
class UpdateFilesetJob
  include Sidekiq::Worker

  def perform(file_set_id)
    file_set = FileSet.find(file_set_id)
    file_set.update_index
    file_set.parent.update_index if parent_needs_reindex?(file_set)
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent

    file_set.parent.thumbnail_id == file_set.id
  end
end
