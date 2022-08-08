# frozen_string_literal: true

RSpec.describe OregonDigital::WorkPermissionChangeJob, type: :job do
  include ActiveJob::TestHelper

  let(:curration_concern) { create(:generic) }
  let(:user) { create(:user) }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  context 'when the job runs' do
    before do
      described_class.perform_now(curration_concern, user)
    end

    it 'sends a message' do
      expect(curration_concern.events.count).to eq 1
    end

    it 'the message mentions the user' do
      expect(curration_concern.events.first[:action]).to include(user.email)
    end
  end

  context 'when the visibility is public' do
    before do
      curration_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      described_class.perform_now(curration_concern, user)
    end

    it 'the message mentions a public visibility' do
      expect(curration_concern.events.last[:action].downcase).to include('public')
    end
  end

  context 'when the visibility is private' do
    before do
      curration_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      described_class.perform_now(curration_concern, user)
    end

    it 'the message mentions a private visibility' do
      expect(curration_concern.events.last[:action].downcase).to include('private')
    end
  end
end
