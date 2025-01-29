# frozen_string_literal: true

module OregonDigital
  # CLASS: Object/methods for use in daily email rake task for failed fetch
  class FailedFetchNotification
    # METHOD: User mapping of all pid
    def user_map
      @user_map ||= []
    end

    # METHOD: Add user to the 'map_user' list
    def add_list_of_users
      # CHECK: See if folder exist
      return unless folder_exist?

      # LOOP: Loop through the directory to check on file
      Dir.foreach('./tmp/failed_fetch/') do |filename|
        # CHECK: Make sure to check for hidden file
        next if (filename == '.') || (filename == '..')

        # GET: Get the id from the txt file and send email to both user and metadata team
        pid = filename.to_s.gsub('.txt', '')

        # STORE: Add user to user_map
        user_map << pid
      end
    end

    # METHOD: Add method to fetch depositor
    def fetch_depositor(pid)
      work = SolrDocument.find(pid)
      work['depositor_ssim'].first
    end

    # METHOD: Add method to fetch a failed file
    def fetch_file(pid)
      Dir.foreach('./tmp/failed_fetch/') do |filename|
        # CHECK: Skip hidden files and special directories
        next if ['.', '..'].include?(filename)

        # GET: Get the id from the txt file
        file_id = filename.to_s.gsub('.txt', '')

        # CHECK: If the pid matches, return the filename
        return filename if file_id == pid
      end
    end

    # METHOD: Return a bool to see if folder exist
    def folder_exist?
      File.exist?('./tmp/failed_fetch/') && !Dir.empty?('./tmp/failed_fetch/')
    end
  end
end
