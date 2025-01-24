# frozen_string_literal:true

RSpec.describe OregonDigital::SiblingsOfWorkSearchBuilder do
  let(:processor_chain) { search_builder.processor_chain }
  let(:solr_params) { {} }
  let(:child) { instance_double('SolrDocument') }
  let(:sibling) { build(:generic, title: ['bar'], id: 124) }
  let(:parent) { build(:generic, title: ['foo'], id: 125) }
  let(:search_builder) { described_class.new(work: child) }

  before do
    allow(child).to receive(:id).and_return(123)
    allow(child).to receive(:parents).and_return([parent])
    allow(parent).to receive(:member_ids).and_return([child.id, sibling.id])
    allow(search_builder).to receive(:blacklight_config)
  end

  describe '#processor_chain' do
    subject { processor_chain }

    it { is_expected.to include :sibling_works }
  end

  describe '#sibling_works' do
    subject { solr_params }

    before do
      search_builder.sibling_works(solr_params)
    end

    it { is_expected.to eq(fq: ['id:(123 OR 124)', '-id:(123)', '-has_model_ssim:*FileSet']) }
  end
end
