# frozen_string_literal: true

require 'zip'

module OregonDigital
  # CLASS: Object/methods for use in daily email rake task for failed fetch
  class FailedFetchNotification
    # METHOD: User mapping of all pid
    def user_map
      @user_map ||= {}
    end

    # METHOD: Add user to the 'map_user' list
    def add_list_of_users
      # CHECK: See if folder exist
      return unless folder_exist?

      # FETCH: Get all of the pids from files
      pid_arr = fetch_pids

      # LOOP: Go through Solr Doc to find depositor to user_map
      solr_docs = SolrDocument.find(pid_arr)
      solr_docs.each do |doc|
        user_map[doc['depositor_ssim'].first] << "#{doc['id']}.txt"
      end
    end

    # METHOD: Add method to fetch metadeities
    def fetch_metadeities
      'kevin.jones@oregonstate.edu'
    end

    # METHOD: Fetch all pids
    def fetch_pids
      # SETUP: Add array to store pids
      pids = []

      # LOOP: Loop through the directory to check on file
      Dir.foreach('./tmp/failed_fetch/') do |filename|
        # CHECK: Make sure to check for hidden file
        next if (filename == '.') || (filename == '..')

        # GET: Get the id from the txt file and send email to both user and metadata team
        pid = filename.to_s.gsub('.txt', '')

        # STORE: Add user to user_map
        pids << pid.to_s
      end

      pids
    end

    # Create zip file to send to metadeities
    def create_zip_file
      # CHECK: Check if file exist if not create a new one
      zip_file = zip_exist

      # ZIP: Add file and zip them together
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
        # LOOP: Loop through the directory to store in zip
        Dir.foreach('./tmp/failed_fetch/') do |filename|
          # CHECK: Make sure to check for hidden file
          next if (filename == '.') || (filename == '..')

          zip.add(filename.to_s, "./tmp/failed_fetch/#{filename}")
        end
      end
    end

    # METHOD: Return a bool to see if folder exist
    def folder_exist?
      File.exist?('./tmp/failed_fetch/') && !Dir.empty?('./tmp/failed_fetch/')
    end

    # METHOD: To check if zip file exist
    def zip_exist
      File.delete('./tmp/failed_fetch_items.zip') if File.file?('./tmp/failed_fetch_items.zip')
      File.new('./tmp/failed_fetch_items.zip', 'w+')
    end
  end
end
