# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'pry'

RSpec.describe 'Rake tasks' do
  include ActiveJob::TestHelper
  describe 'migration:bulk_approve' do
    let(:work1) { build(:work, user: other_user, state: state) }
    let(:migration_user) { User.new(email: 'migrator@example.org') }
    let(:work2) { create(:work, user: migration_user, state: state) }
    let(:other_user) { User.new(email: 'other@example.org') }
    let(:state) { ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive') }
    let(:work3) { build(:work, user: migration_user) }
    let(:workflow) do
      w = create(:workflow)
      w.workflow_states << create(:workflow_state, name: 'pending_review')
      w.workflow_states << create(:workflow_state, name: 'deposited')
      w.save!
      w
    end
    let(:run_rake_task) do
      Rake.application.invoke_task 'migration:bulk_approve'
    end

    before do
      Hyrax::Migrator.config.migration_user = migration_user.email
      Rake.application.rake_require 'tasks/migration/bulk_approve'
      Rake::Task.define_task(:environment)
    end

    context 'when there are migrated assets with state pending_review' do
      before do
        Sipity::Entity.create!(proxy_for_global_id: work2.to_global_id.to_s,
                               workflow_state: workflow.workflow_states.first,
                               workflow: workflow)
        run_rake_task
      end

      it 'approves them' do
        work2.reload
        expect(work2.suppressed?).to eq(false)
        expect(Sipity::Entity(work2).workflow_state_name).to eq('deposited')
        solr = work2.to_solr
        expect(solr['workflow_state_name_ssim']).to eq('deposited')
        expect(solr['suppressed_bsi']).to eq(false)
      end
    end

    # Skipping the next test until LDP::Conflict error (see issue 717) is resolved
    context 'when there are assets from other users' do
      before do
        work1.save!
        Sipity::Entity.create!(proxy_for_global_id: work1.to_global_id.to_s,
                               workflow_state: workflow.workflow_states.first,
                               workflow: workflow)
      end

      xit 'does not get processed' do
        expect(Hyrax::Workflow::ActivateObject).not_to receive(:call).with(target: work1)
        run_rake_task
      end
    end

    # Skipping the next test until LDP::Conflict error (see issue 717) is resolved
    context 'when there is an asset that has not gone through the workflow' do
      xit 'does not get processed' do
        work3.save!
        expect(Hyrax::Workflow::ActivateObject).not_to receive(:call).with(target: work3)
        run_rake_task
      end
    end
  end

  describe 'migration:fixes:retry_file_attach' do
    context 'when there is a batch of persisted assets with no files' do
      let(:migration_user) { User.new(email: 'admin@example.org') }
      let(:work1) { build(:work, user: migration_user, id: 'abcde1234') }
      let(:work2) { build(:work, user: migration_user, id: 'abcde5678') }
      let(:path) { Rails.root.join 'spec/fixtures' }
      let(:upload_file) { Hyrax::UploadedFile.new(user: migration_user, file: file) }
      let(:file) { File.open(File.join(path, 'abcde1234_content.txt')) }
      let(:run_rake_task) do
        ENV['batch'] = 'batch1'
        Rake.application.invoke_task 'migration:fixes:retry_file_attach'
      end

      before do
        work1.save
        work2.save
        migration_user.save
        upload_file.save
        Hyrax::Migrator.config.ingest_local_path = path
        Hyrax::Migrator.config.file_system_path = path
        Rake.application.rake_require 'tasks/migration/fixes'
        Rake::Task.define_task(:environment)
        allow(Hyrax::UploadedFile).to receive(:new).and_return(upload_file)
        run_rake_task
      end

      after do
        clear_enqueued_jobs
        clear_performed_jobs
      end

      it 'enqueues jobs' do
        expect(ActiveJob::Base.queue_adapter.enqueued_jobs.size).to eq 2
      end
    end
  end
end
