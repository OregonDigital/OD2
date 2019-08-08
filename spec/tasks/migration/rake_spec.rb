# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'pry'

RSpec.describe 'Rake tasks' do
  describe 'migration:bulk_approve' do
    let(:migration_user) { User.new(email: 'migrator@example.org') }
    let(:other_user) { User.new(email: 'other@example.org') }
    let(:state) { ::RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive') }
    let(:work1) { create(:work, user: other_user, state: state) }
    let(:work2) { create(:work, user: migration_user, state: state) }
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

    it 'finds all pending assets from the migration_user and approves them' do
      run_rake_task
      work2.reload
      expect(work2.suppressed?).to eq(false)
      expect(work2.to_sipity_entity.workflow_state_name).to eq('deposited')
    end
    it 'ignores assets from other users' do
      run_rake_task
      work1.reload
      expect(work1.suppressed?).to eq(true)
      expect(work1.to_sipity_entity.workflow_state_name).to eq('pending_review')
    end
  end
end
