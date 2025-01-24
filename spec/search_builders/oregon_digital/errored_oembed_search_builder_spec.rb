# frozen_string_literal:true

RSpec.describe OregonDigital::ErroredOembedSearchBuilder do
  subject { processor_chain }

  let(:context) { double }
  let(:search_builder) { described_class.new(context) }
  let(:solr_params) { Blacklight::Solr::Request.new }

  before do
    allow(context).to receive(:blacklight_config)
  end

  describe '#processor_chain' do
    subject { search_builder.processor_chain }

    it { is_expected.to eq %i[with_pagination with_sorting only_oembed with_errored_oembed] }
  end

  describe 'with oembed errors in the database' do
    let!(:oembed_error) { create(:oembed_error) }

    before { search_builder.with_errored_oembed(solr_params) }

    it { expect(solr_params[:fq]).to eq(["id:(#{oembed_error.document_id})"]) }
  end

  describe 'with no errored oembeds' do
    before { search_builder.with_errored_oembed(solr_params) }

    it { expect(solr_params[:fq]).to eq(['-id:*']) }
  end
end
