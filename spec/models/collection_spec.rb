# frozen_string_literal: true

RSpec.describe Collection do
  subject { model }

  let(:model) { build(:collection) }
  let(:prop) { OpenStruct.new(term: 'test_prop') }
  let(:facet) { create(:facet, collection_id: model.id, property_name: prop.term) }

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
      allow(model).to receive(:properties_to_facet).and_return(a: prop)
    end

    it 'adds new facets' do
      before_count = Facet.all.count
      model.send(:generate_default_facets)
      expect(Facet.all.count).to eq(before_count + 1)
    end
  end

  describe 'properties_to_facet' do
    it 'only selects facetable properties' do
      model.send(:properties_to_facet).each do |_key, prop|
        expect(prop.behaviors).to include(:facetable)
      end
    end
  end
end
