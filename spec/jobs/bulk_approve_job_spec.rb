# frozen_string_literal: true

RSpec.describe BulkApproveJob, type: :job do
  include ActiveJob::TestHelper

  let!(:job) { described_class.perform_later(collection_id: col_id, user: user_email) }
  let(:col_id) { 'baseball' }
  let(:user_email) { 'other@example.org' }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'with approve_collection' do
    it { expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq 1 }
  end

  context 'with approve_everything' do
    let!(:job) { described_class.perform_later(collection_id: nil, user: user_email) }

    it { expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq 1 }
  end

  context 'with approve item' do
    let!(:job) { described_class.perform_later(pid: 'abcde1234') }

    it { expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq 1 }
  end
end
