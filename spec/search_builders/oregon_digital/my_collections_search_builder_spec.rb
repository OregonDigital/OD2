# frozen_string_literal:true

RSpec.describe OregonDigital::MyCollectionsSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe '#models' do
    subject { search_builder.models }

    it { is_expected.to eq [::Collection] }
  end
end
