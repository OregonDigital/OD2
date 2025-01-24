# frozen_string_literal:true

RSpec.describe OregonDigital::InReviewSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe '#processor_chain' do
    subject { processor_chain }

    let(:processor_chain) { search_builder.processor_chain }

    it { is_expected.to include(:in_review_ids) }
    it { is_expected.not_to include(:only_active_works) }
  end

  describe '#in_review_ids' do
    subject { solr_params }

    let(:solr_params) { {} }

    before do
      allow(search_builder).to receive(:query).and_return([])
      search_builder.in_review_ids(solr_params)
    end

    it { is_expected.to eq(fq: []) }
  end
end
