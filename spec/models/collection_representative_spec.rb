# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionRepresentative, type: :model do
  subject { model }

  let(:model) { build(:collection_representative) }
  let(:fileset) { build(:file_set) }

  before do
    allow(fileset).to receive(:id).and_return 'abcde1234'
    allow(::FileSet).to receive(:find).with(anything).and_return nil
    allow(::FileSet).to receive(:find).with('abcde1234').and_return fileset
  end

  it { expect(model.collection_id).to be_an_instance_of(String) }
  it { expect(model.fileset_id).to be_an_instance_of(String) }
  it { expect(model.order).to be_an_instance_of(Integer) }

  describe '#fs_title' do
    context 'when the fileset_id is not set' do
      before do
        model.fileset_id = ''
      end

      it 'returns an empty string' do
        expect(model.fs_title).to eq('')
      end
    end

    context 'when the fileset_id is set' do
      before do
        model.fileset_id = fileset.id
      end

      it 'returns the first title of the fileset' do
        expect(model.fs_title).to eq(fileset.title.first)
      end
    end
  end
end
