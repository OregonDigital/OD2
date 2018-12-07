# frozen_string_literal:true

RSpec.describe OregonDigital::ErroredOembedSearchBuilder do
  subject { processor_chain }

  let(:context) { double }
  let(:search_builder) { described_class.new(context) }
  let(:processor_chain) { search_builder.processor_chain }

  describe '#processor_chain' do
    it { is_expected.to eq %i[with_pagination with_sorting only_oembed with_errored_oembed] }
  end

  describe '#with_errored_oembed' do
    let(:processor_chain) { {} }

    before { search_builder.with_errored_oembed(processor_chain) }
    it { is_expected.to eq(fq: 'id:()') }
  end
end
