# frozen_string_literal: true

RSpec.describe Collection do
  subject { model }

  let(:model) { build(:collection, title: ['foo'], depositor: user.email, id: 123) }
  let(:prop) { Blacklight::Configuration::FacetField.new(label: 'test_facet', field: 'test_facet_sim', if: true) }
  let(:user) { create(:user) }
  let(:facet) { create(:facet, collection_id: model.id, property_name: prop.term) }
  let(:term) { OregonDigital::ControlledVocabularies::Resource.new }

  describe 'available_facets' do
    before do
      allow(model).to receive(:generate_default_facets)
      facet.save
    end

    it 'finds existing facets' do
      expect(model.available_facets).to include(facet)
    end

    it 'generates default facets' do
      expect(model).to receive(:generate_default_facets)
      model.available_facets
    end
  end

  describe 'generate_default_facets' do
    before do
      allow(CatalogController.blacklight_config).to receive(:facet_fields).and_return(a: prop)
    end

    it 'adds new facets' do
      before_count = Facet.all.count
      model.send(:generate_default_facets)
      expect(Facet.all.count).to eq(before_count + 1)
    end
  end

  describe '#controlled_property_to_csv_value' do
    before do
      allow(term).to receive(:fetch)
      allow(term).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/TestVocabulary/TestTerm', { label: 'TestTerm$http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }])
    end

    it 'formats a controlled property' do
      expect(model.send(:controlled_property_to_csv_value, term)).to eq('TestTerm')
    end
  end

  describe '#metadata_row' do
    it 'provides an array' do
      expect(model.metadata_row([:title], [])).to be_kind_of(Array)
    end
    it 'provides correct data' do
      data = model.metadata_row(%i[depositor has_model title], [])
      expect(data).to eq([user.email, 'Collection', 'foo'])
    end
  end

  describe '#reindex_extent' do
    it 'returns the config value' do
      expect(OD2::Application.config.reindex_extent).to eq 'full'
      expect(model.reindex_extent).to eq 'full'
    end
  end

  describe '#reindex_extent=' do
    before do
      model.reindex_extent = 'limited'
    end

    it 'allows reindex_extent to be temporarily set' do
      expect(model.reindex_extent).to eq 'limited'
    end
  end
end
