# frozen_string_literal: true

RSpec.describe SolrDocument do
  let(:sd) { described_class.new }
  let(:sd1) { described_class.new({ 'id' => 'bcde12345', 'has_model_ssim' => ['FileSet'] }) }
  let(:sd2) { described_class.new({ 'id' => 'cdef23456', 'has_model_ssim' => ['Image'] }) }
  let(:docs) { [sd1, sd2] }
  let(:ids) { [sd1['id'], sd2['id']] }

  describe 'process_chunk' do
    before do
      allow(sd).to receive(:member_ids).and_return(ids)
      allow(described_class).to receive(:find).and_return(docs)
      OD2::Application.config.max_members_query = 2
      sd.sort_members
    end

    it 'populates children and file_sets' do
      expect(sd.children).to eq [sd2]
      expect(sd.file_sets).to eq [sd1]
    end
  end

  describe 'max_members_query' do
    before do
      allow(sd).to receive(:member_ids).and_return(ids)
      OD2::Application.config.max_members_query = max_members_query
    end

    context 'when chunk size is low' do
      let(:max_members_query) { 100 }
      let(:ids) do
        i = []
        (0..max_members_query).each do |num|
          i << "abc#{num}"
        end
        i
      end

      it 'returns without throwing an error' do
        expect { sd.sort_members }.not_to raise_error
      end
    end

    context 'when chunk size is high' do
      let(:max_members_query) { 1000 }
      let(:ids) do
        i = []
        (0..max_members_query).each do |num|
          i << "abc#{num}"
        end
        i
      end

      it 'throws error' do
        expect { sd.sort_members }.to raise_error(Blacklight::Exceptions::InvalidRequest)
      end
    end
  end
end
