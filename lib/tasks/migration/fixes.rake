# frozen_string_literal: true

namespace :migration do
  namespace :fixes do
    desc 'Fix batch by retrying file attach'
    task retry_file_attach: :environment do
      batch = ENV['batch']

      batch_path = File.join(Hyrax::Migrator.config.ingest_local_path, batch)

      pids = Dir.entries(batch_path)
                .select { |e| File.file?(File.join(batch_path, e)) && File.extname(e) == '.zip' }
                .map { |zip_file| File.basename(zip_file, File.extname(zip_file)) }

      pids.each do |pid|
        af_object = ActiveFedora::Base.exists?(pid) ? ActiveFedora::Base.find(pid) : nil
        if !af_object.nil? && af_object.representative_id.nil?
          attach_file(af_object)
        end
      end
    end

    desc 'Fix one asset by retrying file attach'
    task retry_single_file_attach: :environment do
      pid = ENV['pid']
      af_object = ActiveFedora::Base.exists?(pid) ? ActiveFedora::Base.find(pid) : nil
        if !af_object.nil? && af_object.representative_id.nil?
          attach_file(af_object)
        end
      end
    end
  end
end


def attach_file(af_object)
  user = User.find_by_user_key(Hyrax::Migrator.config.migration_user)
  files = Dir.entries(Hyrax::Migrator.config.file_system_path)

  filename = files.find { |f| f.downcase.start_with? (af_object.id) }

  file = File.open(File.join(Hyrax::Migrator.config.file_system_path, filename))
  uploaded_file = Hyrax::UploadedFile.new(user: user, file: file)
  uploaded_file.save
  puts "enqueueing job for #{af_object.id}"
  AttachFilesToWorkJob.perform_later(af_object, [uploaded_file])
end

