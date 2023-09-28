# frozen_string_literal:true

Rails.application.config.to_prepare do
  Hyrax::Actors::CreateWithRemoteFilesActor::IngestRemoteFilesService.class_eval do
    # @return [TrueClass]
    def attach!
      return true unless remote_files
      remote_files.each do |file_info|
        next if file_info.blank? || file_info[:url].blank?
        ## Begin Hack/fix, see https://github.com/samvera/hyrax/issues/3474
        # Escape any space characters, so that this is a legal URI,
        # maintaining previously escaped characters
        # Regex for a case insensitive double-encoded percent character followed
        # by the original hex, such as %2F => %252F
        uri = URI.parse(Addressable::URI.escape(file_info[:url]).gsub(/%25([0-9a-f]{2})/i, '%\1'))
        unless self.class.validate_remote_url(uri)
          Rails.logger.error "User #{user.user_key} attempted to ingest file from url #{file_info[:url]}, which doesn't pass validation"
          return false
        end
        auth_header = file_info.fetch(:auth_header, {})
        create_file_from_url(uri, file_info[:file_name], auth_header)
      end
      add_ordered_members! if ordered
      true
    end
  end
end
