# frozen_string_literal:true
Rails.application.config.to_prepare do
  Bulkrax::FileFactory::InnerWorkings.class_eval do
    ##
    # @return [Array<Integer>] An array of Hyrax::UploadFile#id representing the
    #         files that we should be uploading.
    def import_files
      paths = file_paths.map { |path| import_file(path) }.compact
      # OVERRIDE FROM BULKRAX: We don't want to remove/tombstone existing filesets when updating files on a work.
      #   Here we added the check for if this is an update (@update_files).
      set_removed_filesets if @update_files && local_file_sets.present?
      paths
    end
  end
end