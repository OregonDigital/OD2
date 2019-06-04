# frozen_string_literal: true

RSpec.describe Collection do
  subject { model }

  let(:model) { build(:collection) }
  let(:prop) { Blacklight::Configuration::FacetField.new(label: 'test_facet', field: 'test_facet_sim', if: true) }
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
      allow(CatalogController.blacklight_config).to receive(:facet_fields).and_return(a: prop)
    end

    it 'adds new facets' do
      before_count = Facet.all.count
      model.send(:generate_default_facets)
      expect(Facet.all.count).to eq(before_count + 1)
    end
  end
end
