# frozen_string_literal: true

RSpec.describe BlacklightOaiProvider::SolrDocumentWrapper do
  subject(:wrapper) { described_class.new(controller, options) }

  let(:options) { {} }
  let(:controller_class) { CatalogController }
  let(:controller) { instance_double(controller_class) }
  let(:blacklight_config) { Blacklight::Configuration.new }

  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:uri_show) { 'https://localhost:3000/concern/images/abcde1234' }
  let(:uri_thumb) { 'http://localhost:8080/iiif/f0/ab/cd/e1/23/4-jp2.jp2/full/430,/0/default.jpg' }

  shared_context 'with timestamp_searches' do
    let(:expected_timestamp) { '2014-02-03 18:42:53.056000000 +0000' }
    let(:attributes) do
      {
        'id' => 'abcde1234',
        'has_model_ssim' => ['Image'],
        'thumbnail_path_ss' => '/downloads/abcde1234?file=thumbnail',
        'member_ids_ssim' => ['f0abcde1234'],
        'timestamp' => expected_timestamp
      }
    end
    let(:repository) { instance_double(Blacklight::Solr::Repository) }
    let(:search_builder) { instance_double(Blacklight::SearchBuilder) }
    let(:search_service) { instance_double(Blacklight::SearchService) }
    let(:documents) { [SolrDocument.new(attributes)] }
    let(:response) { OpenStruct.new(documents: documents, total: documents.length) }

    before do
      allow(controller).to receive_messages(params: {}, blacklight_config: blacklight_config)
      # allow(controller).to receive(:params).and_return({})
      allow(controller).to receive(:current_ability).and_return(ability)
      allow(controller).to receive(:search_service).and_return(search_service)
      allow(search_service).to receive_messages(repository: repository, search_builder: search_builder)
    end
  end

  # Temporarily skipped with xit
  describe '#find' do
    subject(:result) { wrapper.find(selector) }

    include_context 'with timestamp_searches'

    context 'when selector is :all' do
      let(:selector) { :all }
      let(:query) { {} }
      let(:limit) { 1 }

      before do
        allow(search_builder).to receive_messages(merge: search_builder, query: query)
        allow(repository).to receive(:search).with(query).and_return(response)
      end

      it 'returns a document with show and thumb uris' do
        results = wrapper.find(:all)
        expect(results.first['identifier_tesim']).to include(uri_show)
        expect(results.first['identifier_tesim']).to include(uri_thumb)
      end
    end

    # Temporarily skipped with xit
    context 'when selector is an individual record' do
      let(:selector) { 'abcde1234' }
      let(:query) { {} }

      before do
        allow(search_builder).to receive(:query).and_return(query)
        allow(repository).to receive(:search).with(query).and_return(response)
        allow(search_builder).to receive(:where).with({ 'id' => selector }).and_return(search_builder)
      end

      it 'returns a document with show and thumb uris' do
        results = wrapper.find(selector)
        expect(results['identifier_tesim']).to include(uri_show)
        expect(results['identifier_tesim']).to include(uri_thumb)
      end
    end
  end

  # Temporarily skipped with xit
  describe '#select_partial' do
    include_context 'with timestamp_searches'
    let(:token) { BlacklightOaiProvider::ResumptionToken.new({ last: 0 }, nil, 1) }
    let(:next_response) { OpenStruct.new(documents: documents, total: documents.length) }

    before do
      allow(search_builder).to receive_messages(merge: search_builder, query: {})
      allow(repository).to receive(:search).with({}).and_return(response)
      allow(repository).to receive(:search).with(hash_including(start: 0)).and_return(next_response)
    end

    it 'returns a document with show and thumb uris' do
      partial_result = wrapper.select_partial(token)
      expect(partial_result.records.first['identifier_tesim']).to include(uri_show)
      expect(partial_result.records.first['identifier_tesim']).to include(uri_thumb)
    end
  end
end
