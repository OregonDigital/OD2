# frozen_string_literal:true

RSpec.describe OregonDigital::ChildrenOfWorkSearchBuilder do
  let(:processor_chain) { search_builder.processor_chain }
  let(:solr_params) { {} }
  let(:child1) { build(:generic, title: ['foo'], id: 123) }
  let(:child2) { build(:generic, title: ['foo'], id: 124) }
  let(:parent) { build(:generic, title: ['foo'], id: 125) }
  let(:search_builder) { described_class.new(work: parent) }

  before do
    allow(parent).to receive(:[]).with('member_ids_ssim').and_return([child1.id, child2.id])
    allow(search_builder).to receive(:blacklight_config)
  end

  describe '#processor_chain' do
    subject { processor_chain }

    it { is_expected.to include :child_works }
  end

  describe '#child_works' do
    subject { solr_params }

    before do
      search_builder.child_works(solr_params)
    end

    it { is_expected.to eq(fq: ['id:(123 OR 124)', '-has_model_ssim:*FileSet']) }
  end
end
