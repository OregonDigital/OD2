RSpec.describe OregonDigital::OembedSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe "#processor_chain" do
    subject { search_builder.processor_chain }

    it { is_expected.to eq [:with_pagination, :with_sorting, :only_oembed] }
  end

  describe "#with_sorting" do
    subject { {} }

    before { search_builder.with_sorting(subject) }
    it { is_expected.to eq(sort: 'system_create_dtsi desc') }
  end

  describe "#only_oembed" do
    subject { {} }

    before { search_builder.only_oembed(subject) }
    it { is_expected.to eq(fq: 'oembed_url_tesim:*') }
  end
end
