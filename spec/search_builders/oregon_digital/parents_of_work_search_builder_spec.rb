# frozen_string_literal:true

RSpec.describe OregonDigital::ParentsOfWorkSearchBuilder do
  let(:processor_chain) { search_builder.processor_chain }
  let(:child) { build(:generic, title: ['foo'], id: 123) }
  let(:parent) { build(:generic, title: ['foo'], id: 124, member_ids: [child.id]) }
  let(:search_builder) { described_class.new(child) }

  describe '#processor_chain' do
    subject { search_builder.processor_chain }

    it { is_expected.to eq %i[parent_works] }
  end

  describe '#parent_works' do
    before { search_builder.parent_works({}) }

    it { is_expected.to eq(fq: ['member_ids_ssim:(123)']) }
  end
end
