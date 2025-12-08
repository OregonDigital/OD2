# frozen_string_literal: true

RSpec.describe OregonDigital::VerifyCollectionsService do
  let(:work) { double }
  let(:service) { described_class.new({ work: work, solr_doc: solr_doc }) }
  let(:solr_doc) do
    {
      'id' => 'abcde1234',
      'member_of_collection_ids_ssim' => %w[hello-kitty my-little-pony]
    }
  end

  # rubocop:disable RSpec/NestedGroups
  describe 'verify' do
    context 'when there is a collection set' do
      before do
        allow(work).to receive(:member_of_collection_ids).and_return(%w[my-little-pony hello-kitty])
      end

      context 'when collection is in solr' do
        it 'returns an empty hash' do
          expect(service.verify).to eq({ collections: [] })
        end
      end

      context 'when collection is not in solr' do
        let(:solr_doc) { { 'id' => 'abcde1234' } }

        it 'returns an error' do
          expect(service.verify).to eq({ collections: ['SOLR discrepancy'] })
        end
      end
    end

    context 'when there is no collection set' do
      before do
        allow(work).to receive(:member_of_collection_ids).and_return([])
      end

      it 'returns an error' do
        expect(service.verify).to eq({ collections: ['no colls found'] })
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
