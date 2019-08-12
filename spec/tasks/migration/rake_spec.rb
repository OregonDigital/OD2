# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'pry'

RSpec.describe 'Rake tasks' do
  describe 'migration:bulk_approve' do
    let(:work1) { create(:work, user: other_user, state: state) }
    let(:migration_user) { User.new(email: 'migrator@example.org') }
    let(:work2) { create(:work, user: migration_user, state: state) }
    let(:other_user) { User.new(email: 'other@example.org') }
    let(:state) { ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive') }
    let(:work3) { create(:work, user: migration_user) }
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
      Sipity::Entity.create!(proxy_for_global_id: work1.to_global_id.to_s,
                             workflow_state: workflow.workflow_states.first,
                             workflow: workflow)
      Sipity::Entity.create!(proxy_for_global_id: work2.to_global_id.to_s,
                             workflow_state: workflow.workflow_states.first,
                             workflow: workflow)
    end

    context 'when there are migrated assets with state pending_review' do
      before do
        run_rake_task
        work2.reload
      end

      it 'approves them' do
        expect(work2.suppressed?).to eq(false)
        expect(work2.to_sipity_entity.workflow_state_name).to eq('deposited')
      end
      it 'changes the values in solr' do
        work2.reload
        solr = work2.to_solr
        expect(solr['workflow_state_name_ssim']).to eq('deposited')
        expect(solr['suppressed_bsi']).to eq(false)
      end
    end

    context 'when there are assets from other users' do
      it 'does not get processed' do
        expect(Hyrax::Workflow::ActivateObject).not_to receive(:call).with(target: work1)
        run_rake_task
      end
    end

    context 'when there is an asset that has not gone through the workflow' do
      it 'does not get processed' do
        expect(Hyrax::Workflow::ActivateObject).not_to receive(:call).with(target: work3)
        run_rake_task
      end
    end
  end
end
