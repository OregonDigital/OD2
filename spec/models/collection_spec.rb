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

  describe '#controlled_properties_as_s' do
    it 'tries to format all controlled properties' do
      model.controlled_properties.map { |prop| expect(model).to receive(prop.to_s) }
      model.send(:controlled_properties_as_s)
    end
    it 'returns an empty hash with no controlled properties' do
      expect(model.send(:controlled_properties_as_s)).to eq({})
    end
  end

  describe '#properties_as_s' do
    it 'tries to format the correct properties' do
      rejected_fields = %w[head tail] + model.controlled_properties.map(&:to_sym)
      (model.send(:properties).keys - rejected_fields).map { |prop| expect(model).to receive(prop.to_s) }
      model.send(:properties_as_s)
    end
    it 'returns a hash with no controlled properties' do
      expect(model.send(:properties_as_s)).to eq('depositor' => user.email, 'has_model' => 'Collection', 'title' => 'foo')
    end
  end

  describe '#csv_metadata' do
    it 'provides a string' do
      expect(model.csv_metadata).to be_kind_of(String)
    end
    it 'provides correct data' do
      csv = CSV.parse(model.csv_metadata, headers: true)
      expect(csv[0].to_h).to eq('depositor' => user.email, 'has_model' => 'Collection', 'title' => 'foo')
    end
  end
end
