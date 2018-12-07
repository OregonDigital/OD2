# frozen_string_literal:true

RSpec.describe OregonDigital::ErroredOembedSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe '#processor_chain' do
    subject { search_builder.processor_chain }

    it { is_expected.to eq %i[with_pagination with_sorting only_oembed with_errored_oembed] }
  end

  context 'with errored oembeds' do
    let(:solr_params) { Blacklight::Solr::Request.new }

    describe 'having none in the database' do
      before { search_builder.with_errored_oembed(solr_params) }
      it { expect(solr_params[:fq]).to eq([]) }
    end

    describe 'having some in the database' do
      let!(:oembed_error) { create(:oembed_error) }

      before { search_builder.with_errored_oembed(solr_params) }
      it { expect(solr_params[:fq]).to eq("id:(#{oembed_error.document_id})") }
    end
  end
end
