# frozen_string_literal:true

RSpec.describe OregonDigital::OembedSearchBuilder do
  subject { processor_chain }

  let(:processor_chain) { search_builder.processor_chain }
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  before do
    allow(context).to receive(:blacklight_config)
  end

  describe '#processor_chain' do
    it { is_expected.to eq %i[with_pagination with_sorting only_oembed] }
  end

  describe '#with_sorting' do
    let(:processor_chain) { {} }

    before { search_builder.with_sorting(processor_chain) }

    it { is_expected.to eq(sort: 'system_create_dtsi desc') }
  end

  describe '#only_oembed' do
    let(:processor_chain) { {} }

    before { search_builder.only_oembed(processor_chain) }

    it { is_expected.to eq(fq: ['oembed_url_sim:*', 'has_model_ssim:*FileSet']) }
  end
end
