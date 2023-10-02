# frozen_string_literal: true

namespace :migration do
  desc 'ingest migration'
  task ingest: :environment do
    collection = ENV['collection']

    batch_path = File.join('/data/tmp', collection)

    pids = Dir.entries(batch_path)
              .select { |e| File.file?(File.join(batch_path, e)) && File.extname(e) == '.zip' }
              .map { |zip_file| File.basename(zip_file, File.extname(zip_file)) }

    pids.each do |pid|
      Hyrax::Migrator.config.skip_field_mode = true
      Hyrax::Migrator.config.upload_storage_service = :file_system
      Hyrax::Migrator.config.ingest_storage_service = :file_system
      Hyrax::Migrator.config.file_system_path = '/data/tmp'
      Hyrax::Migrator.config.ingest_local_path = '/data/tmp'

      file_path = "/data/tmp/#{collection}/#{pid}.zip"

      cleanup(pid)

      w = Hyrax::Migrator::Work.create(pid: pid, file_path: file_path)
      m = Hyrax::Migrator::Middleware.default
      m.start(w)
    end
  end
end

def cleanup(pid)
  gid = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid).to_global_id.to_s if ActiveFedora::Base.exists?(pid)
  Sipity::Entity.find_by(proxy_for_global_id: gid).delete if Sipity::Entity.find_by(proxy_for_global_id: gid).present?
  af_cleanup(pid)
  Hyrax::Migrator::Work.find_by_pid(pid).delete if Hyrax::Migrator::Work.find_by_pid(pid).present?
end

def af_cleanup(pid)
  Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid).delete if ActiveFedora::Base.exists?(pid)
  ActiveFedora::Base.eradicate(pid)
end
