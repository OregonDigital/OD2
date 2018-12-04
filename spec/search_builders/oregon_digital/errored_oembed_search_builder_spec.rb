RSpec.describe OregonDigital::ErroredOembedSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe "#processor_chain" do
    subject { search_builder.processor_chain }

    it { is_expected.to eq [:with_pagination, :with_sorting, :only_oembed, :with_errored_oembed] }
  end

  describe "#with_errored_oembed" do
    subject { {} }

    before { search_builder.with_errored_oembed(subject) }
    it { is_expected.to eq(fq: 'id:()') }
  end
end
