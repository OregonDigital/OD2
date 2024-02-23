# frozen_string_literal:true

RSpec.describe OregonDigital::BatchVerificationService do
  let(:service) { described_class.new(pids) }
  let(:pids) { ['df65vc341'] }

  describe '#verify' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    context 'when given a batch' do
      it 'enqueues one job for each bag in batch_name' do
        service.verify
        expect(OregonDigital::VerifyWorkJob).to have_been_enqueued.exactly(1).times
      end
    end

    context 'when given an extra argument' do
      let(:service) { described_class.new(pids, { fruit: 'banana' }) }

      it 'passes it along' do
        service.verify
        expect(OregonDigital::VerifyWorkJob).to have_been_enqueued.with({ fruit: 'banana', pid: 'df65vc341' })
      end
    end
  end
end
