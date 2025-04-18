# frozen_string_literal: true

RSpec.describe OregonDigital::VerifyWorkJob, type: :job do
  include ActiveJob::TestHelper
  let(:pid) { 'abcde1234' }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'when there is a job to run' do
    let(:job) { described_class.perform_later(pid: pid, size: 1) }
    let(:service) { double }
    let(:work) { double }

    before do
      allow(OregonDigital::VerifyWorkService).to receive(:new).and_return(service)
      allow(service).to receive(:run)
    end

    it 'instantiates and calls the service' do
      expect(OregonDigital::VerifyWorkService).to receive(:new)
      perform_enqueued_jobs { job }
    end
  end

  context 'when there is a job to be queued' do
    let!(:job) { described_class.perform_later(pid: pid) }

    it 'shows up in the queue' do
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq 1
    end
  end
end
