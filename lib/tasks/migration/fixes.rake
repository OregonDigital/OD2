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
        assess(pid)
      end
    end

    desc 'Fix one asset by retrying file attach'
    task retry_single_file_attach: :environment do
      pid = ENV['pid']
      assess(pid)
    end

    desc 'Create workflow entity if it does not exist'
    task create_workflow_entity do
      pid = ENV['pid']
      work = ActiveFedora::Base.find(pid)
      work_global_id = work.to_global_id.to_s
      if Sipity::Entity.where(proxy_for_global_id: work_global_id).empty? && work.admin_set_id.present?
        workflow_id = Sipity::Workflow.find_active_workflow_for(admin_set_id: work.admin_set_id).id
        # assuming the one step workflow
        workflow_state_id = Sipity::WorkflowState.find_by(workflow_id: workflow_id, name: 'pending_review').id
        se = Sipity::Entity.new(proxy_for_global_id: work_global_id, workflow_id: workflow_id, workflow_state_id: workflow_state_id)
        se.save
      end
    end
  end
end

def assess(pid)
  af_object = ActiveFedora::Base.exists?(pid) ? ActiveFedora::Base.find(pid) : nil
  attach_file(af_object) if !af_object.nil? && af_object.representative_id.nil?
end

# Looks for the content file in the file_system_path
# TODO Enable retrieving content file from the zip?
def attach_file(af_object)
  filename = files.find { |f| f.downcase.start_with? af_object.id }
  puts "Unable to find content file for #{af_object.id}" && return if filename.nil?

  puts "Enqueueing job for #{af_object.id}"
  AttachFilesToWorkJob.perform_later(af_object, [upload_file(migration_user, filename)])
end

def migration_user
  @migration_user ||= User.where(email: Hyrax::Migrator.config.migration_user).first
end

def files
  @files ||= Dir.entries(Hyrax::Migrator.config.file_system_path)
end

def upload_file(migration_user, filename)
  file = File.open(File.join(Hyrax::Migrator.config.file_system_path, filename))
  uploaded_file = Hyrax::UploadedFile.new(user: migration_user, file: file)
  uploaded_file.save
  uploaded_file
end
