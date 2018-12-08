# frozen_string_literal:true

RSpec.describe OregonDigital::ErroredOembedSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }
  let(:solr_params) { Blacklight::Solr::Request.new }

  describe '#processor_chain' do
    subject { search_builder.processor_chain }

    it { is_expected.to eq %i[with_pagination with_sorting only_oembed with_errored_oembed] }
  end

  describe 'with oember errors in the database' do
    let!(:oembed_error) { create(:oembed_error) }

    before { search_builder.with_errored_oembed(solr_params) }
    it { expect(solr_params[:fq]).to eq(["id:(#{oembed_error.document_id})"]) }

    context 'with a filter already set' do
      let(:solr_params) { Blacklight::Solr::Request.new(fq: ['test']) }

      it 'makes a proper composite query when filters exist' do
        expect(solr_params[:fq]).to eq(['test', " AND id:(#{oembed_error.document_id})"])
      end
    end
  end

  describe 'with no errored oembeds' do
    before { search_builder.with_errored_oembed(solr_params) }
    it { expect(solr_params[:fq]).to eq(['-id:*']) }

    context 'with a filter already set' do
      let(:solr_params) { Blacklight::Solr::Request.new(fq: ['test']) }

      it 'makes a proper composite query when filters exist' do
        expect(solr_params[:fq]).to eq(['test', ' AND -id:*'])
      end
    end
  end
end
