# frozen_string_literal: true

RSpec.describe OaiSet do
  let(:controller) { CatalogController.new }
  let(:fields) { [{ label: 'id', solr_field: 'member_of_collection_ids_ssim' }] }
  let(:coll) { build(:collection, id: 'bananas-from-space_oai', title: ['Bananas from Space'], collection_type_gid: "gid://od2/hyrax-collectiontype/#{oai_collection_type.id}") }
  let(:oai_collection_type) { create(:collection_type, machine_id: :oai_set) }

  before do
    described_class.controller = controller
    described_class.fields = fields
    allow(controller).to receive(:params).and_return({})
    allow(ActiveFedora::Base).to receive(:find).and_return(coll)
  end

  describe 'from_spec' do
    before do
      allow(Hyrax::SolrService).to receive(:query).and_return(['banana'])
    end

    context 'with label' do
      let(:spec) { 'id:bananas-from-space' }

      it 'delivers correct solr arg' do
        expect(described_class.from_spec(spec)).to eq 'member_of_collection_ids_ssim:bananas-from-space'
      end
    end

    context 'without label' do
      let(:spec) { 'bananas-from-space' }

      it 'delivers correct solr arg' do
        expect(described_class.from_spec(spec)).to eq 'member_of_collection_ids_ssim:bananas-from-space'
      end
    end
  end

  describe 'sets_for' do
    let(:record) { { 'member_of_collection_ids_ssim' => ['bananas-from-space_oai'] } }
    let(:sets) { [described_class.new('bananas-from-space_oai')] }

    before do
      allow(Hyrax::SolrService).to receive(:query).and_return([{ 'title_tesim' => ['Bananas from Space'] }])
    end

    it 'delivers an array of OaiSets' do
      expect(described_class.sets_for(record).first.value).to eq sets.first.value
    end
  end
end
