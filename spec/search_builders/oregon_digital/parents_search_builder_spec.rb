# frozen_string_literal:true

RSpec.describe OregonDigital::ParentsSearchBuilder do
  let(:processor_chain) { search_builder.processor_chain }
  let(:solr_params) { {} }
  let(:child) { build(:generic, title: ['foo'], id: 123) }
  let(:parent) { build(:generic, title: ['foo'], id: 124, member_ids: [child.id]) }
  let(:search_builder) { described_class.new(id: child.id) }

  before do
    allow(context).to receive(:blacklight_config)
  end

  describe '#processor_chain' do
    subject { processor_chain }

    it { is_expected.to include :parent_works }
  end

  describe '#parent_works' do
    subject { solr_params }

    before { search_builder.parent_works(solr_params) }

    it { is_expected.to eq(fq: ['member_ids_ssim:(123)']) }
  end
end
