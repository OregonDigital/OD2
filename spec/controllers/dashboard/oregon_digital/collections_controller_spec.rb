# frozen_string_literal: true

RSpec.describe Dashboard::OregonDigital::CollectionsController, type: :controller do
  let(:valid_params) do
    {
      facet_configuration: 'facet[]=1&facet[]=0',
      facet_label_0: 'label0',
      facet_enabled_0: '1',
      facet_label_1: 'label1',
      facet_enabled_1: '0'
    }
  end
  let(:facet0) { create(:facet, id: 0) }
  let(:facet1) { create(:facet, id: 1) }

  describe '#process_facets' do
    before do
      controller.params = valid_params
      facet0.save
      facet1.save
      controller.send(:process_facets)
    end
    let(:facet) { Facet.find(0) }

    it 'creates the right number of facets' do
      expect(Facet.all.count).to eq(2)
    end

    it 'creates facet 0 with proper label' do
      expect(facet.label).to eq('label0')
    end

    it 'creates facet 0 enabled' do
      expect(facet.enabled).to eq(true)
    end

    it 'creates facet 0 in correct order' do
      expect(facet.order).to eq(1)
    end
  end
end
