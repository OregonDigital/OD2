# frozen_string_literal: true

require 'zip'

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

      # FETCH: Get all of the pids from files
      pid_arr = fetch_pids

      # LOOP: Go through Solr Doc to find depositor to user_map
      solr_docs = SolrDocument.find(pid_arr)
      solr_docs.each do |doc|
        user_map << { doc['depositor_ssim'].first => "#{doc['id']}.txt" }
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

      # FETCH: Ensure the directory exists and is not empty
      fetch_dir = Rails.root.join('tmp', 'failed_fetch').to_s

      # LOOP: Loop through the directory to check on file
      Dir.foreach(fetch_dir) do |filename|
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
      # GET: Get path to folder
      dir_path = Rails.root.join('tmp', 'failed_fetch').to_s

      # CHECK: Ensure the directory exists and is not empty
      return unless folder_exist?

      # CHECK: Check if file exist if not create a new one
      zip_file = zip_exist

      # ZIP: Add file and zip them together
      Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
        # LOOP: Loop through the directory to store in zip
        Dir.foreach(dir_path) do |filename|
          # CHECK: Make sure to check for hidden file
          next if (filename == '.') || (filename == '..')

          # PATH: Full path to the file
          file_path = File.join(dir_path, filename)

          zip.add(filename.to_s, file_path)
        end
      end
    end

    # METHOD: Return a bool to see if folder exist
    def folder_exist?
      dir_path = Rails.root.join('tmp', 'failed_fetch').to_s
      File.exist?(dir_path) && !Dir.empty?(dir_path)
    end

    # METHOD: To check if zip file exist
    def zip_exist
      zip_path = Rails.root.join('tmp', 'failed_fetch_items.zip').to_s
      File.delete(zip_path) if File.file?(zip_path)
      File.new(zip_path, 'w+')
    end

    # METHOD: Delete all files in folder to clear up
    def delete_files
      # PATH: Define the folder path using Rails.root.join for safety
      folder = Rails.root.join('tmp', 'failed_fetch').to_s

      # CHECK: Check if the directory exists before trying to delete files
      return unless Dir.exist?(folder)

      # LOOP: Go through and delete the files
      Dir.glob("#{folder}/*").each do |file|
        File.delete(file) if File.file?(file)  # Ensure only files are deleted
      end
    end
  end
end
