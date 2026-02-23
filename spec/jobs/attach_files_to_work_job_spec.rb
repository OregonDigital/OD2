# frozen_string_literal: true

RSpec.describe AttachFilesToWorkJob, perform_enqueued: [AttachFilesToWorkJob] do
  let(:file1) { File.open(fixture_path + '/test.jpg') }
  let(:file2) { File.open(fixture_path + '/test.jpg') }
  let(:uploaded_file1) { build(:uploaded_file, file: file1) }
  let(:uploaded_file2) { build(:uploaded_file, file: file2) }
  let(:user) { create(:user, email: 'user@banana.org') }

  context 'when use_valkyrie is false' do
    let(:generic_work) { create(:generic, depositor: user.email, visibility: 'open') }

    before do
      allow(CharacterizeJob).to receive(:perform_later)
    end

    context 'when the work has no filesets' do
      it 'attaches files' do
        described_class.perform_now(generic_work, [uploaded_file1])
        generic_work.reload
        expect(generic_work.file_sets.count).to eq 1
        expect(generic_work.file_sets.map(&:visibility)).to all(eq 'open')
        expect(uploaded_file1.reload.file_set_uri).not_to be_nil
        expect(generic_work.file_sets.first.id).to eq("f0#{generic_work.id}")
      end
    end

    context 'when the work already has a fileset' do
      before do
        described_class.perform_now(generic_work, [uploaded_file1])
        generic_work.reload
      end

      it 'attaches files' do
        described_class.perform_now(generic_work, [uploaded_file2])
        generic_work.reload
        expect(generic_work.file_sets.count).to eq 2
        expect(generic_work.file_sets[1].id).to eq("f1#{generic_work.id}")
      end
    end

    context 'when the work has a deleted fileset' do
      let(:deleted_fs) { create(:file_set, id: "f0#{generic_work.id}", depositor: user.email, visibility: 'open') }

      before do
        deleted_fs.delete
      end

      it 'attaches files singly' do
        described_class.perform_now(generic_work, [uploaded_file1])
        generic_work.reload
        expect(generic_work.file_sets.count).to eq 1
        expect(generic_work.file_sets[0].id).to eq("f1#{generic_work.id}")
        described_class.perform_now(generic_work, [uploaded_file2])
        generic_work.reload
        expect(generic_work.file_sets.count).to eq 2
        expect(generic_work.file_sets[1].id).to eq("f2#{generic_work.id}")
      end

      it 'attaches multiple files' do
        described_class.perform_now(generic_work, [uploaded_file1, uploaded_file2])
        generic_work.reload
        expect(generic_work.file_sets.count).to eq 2
        expect(generic_work.file_sets[0].id).to eq("f1#{generic_work.id}")
        expect(generic_work.file_sets[1].id).to eq("f2#{generic_work.id}")
      end
    end
  end
end
