# frozen_string_literal: true

RSpec.describe AttachFilesToWorkJob, perform_enqueued: [AttachFilesToWorkJob] do
  let(:file1) { File.open(fixture_path + '/test.jpg') }
  let(:uploaded_file1) { build(:uploaded_file, file: file1) }
  let(:user) { create(:user, email: 'user@banana.org') }

  context 'when use_valkyrie is false' do
    let(:generic_work) { create(:generic, depositor: user.email, visibility: 'open') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    it 'attaches files' do
      described_class.perform_now(generic_work, [uploaded_file1])
      generic_work.reload
      expect(generic_work.file_sets.count).to eq 1
      expect(generic_work.file_sets.map(&:visibility)).to all(eq 'open')
      expect(uploaded_file1.reload.file_set_uri).not_to be_nil
      expect(generic_work.file_sets.first.id).to eq("f0#{generic_work.id}")
    end
  end
end
