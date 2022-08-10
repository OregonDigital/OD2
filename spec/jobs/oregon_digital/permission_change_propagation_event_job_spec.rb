# frozen_string_literal: true

RSpec.describe OregonDigital::PermissionChangePropagationEventJob, type: :job do
  include ActiveJob::TestHelper

  let(:curation_concern) { create(:generic) }
  let(:file_set) { create(:file_set) }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'when the job runs' do
    before do
      described_class.perform_now(file_set, curation_concern)
    end

    it 'sends a message' do
      expect(file_set.events.count).to eq 1
    end

    it 'the message mentions the parent' do
      expect(file_set.events.first[:action]).to include(curation_concern.title.first)
    end
  end

  context 'when the visibility is public' do
    before do
      file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      described_class.perform_now(file_set, curation_concern)
    end

    it 'the message mentions a public visibility' do
      expect(file_set.events.last[:action].downcase).to include('public')
    end
  end

  context 'when the visibility is private' do
    before do
      file_set.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      described_class.perform_now(file_set, curation_concern)
    end

    it 'the message mentions a private visibility' do
      expect(file_set.events.last[:action].downcase).to include('private')
    end
  end
end
