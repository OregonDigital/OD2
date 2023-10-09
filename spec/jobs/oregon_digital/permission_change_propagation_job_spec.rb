# frozen_string_literal: true

RSpec.describe OregonDigital::PermissionChangePropagationJob, type: :job do
  include ActiveJob::TestHelper

  let(:curation_concern) do
    cc = create(:image).valkyrie_resource
    cc.member_ids << file_set.id
    Hyrax.persister.save(resource: cc)
  end
  let(:file_set) { create(:file_set).valkyrie_resource }
  let(:event_job_class) { OregonDigital::PermissionChangePropagationEventJob }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'when the job runs' do
    it 'enqueues the child job' do
      expect(OregonDigital::PermissionChangePropagationEventJob).to receive(:perform_later).with(file_set, curation_concern)
      described_class.perform_now(curation_concern)
    end
  end
end
