# frozen_string_literal: true

RSpec.describe BlacklightOaiProvider::SolrDocumentWrapper do
  subject(:wrapper) { described_class.new(controller, options) }

  let(:options) { {} }
  let(:controller) { CatalogController.new }
  let(:repository) { double }
  let(:response) { double }
  let(:doc) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'id' => 'abcde1234',
      'has_model_ssim' => ['Image'],
      'thumbnail_path_ss' => '/downloads/abcde1234?file=thumbnail',
      'member_ids_ssim' => ['f0abcde1234']
    }
  end
  let(:documents) { [doc] }
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:oai_collection_type) { create(:collection_type, machine_id: :oai_set) }
  let(:user_collection_type) { create(:collection_type, machine_id: :user_collection) }
  let(:uri_show) { 'https://localhost:3000/concern/images/abcde1234' }
  let(:uri_thumb) { 'http://localhost:8080/iiif/f0/ab/cd/e1/23/4-jp2.jp2/full/430,/0/default.jpg' }

  before do
    allow(controller).to receive(:params).and_return({})
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :oai_set).and_return(oai_collection_type)
    allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :user_collection).and_return(user_collection_type)
    allow(controller).to receive(:repository).and_return(repository)
    allow(repository).to receive(:search).and_return(response)
    allow(response).to receive(:documents).and_return(documents)
    allow(response).to receive(:total).and_return(1)
  end

  describe '#find' do
    context 'when selector is :all' do
      it 'returns a document with show and thumb uris' do
        results = wrapper.find(:all)
        expect(results.first['identifier_tesim']).to include(uri_show)
        expect(results.first['identifier_tesim']).to include(uri_thumb)
      end
    end

    context 'when selector is an individual record' do
      it 'returns a document with show and thumb uris' do
        results = wrapper.find('abcde1234')
        expect(results['identifier_tesim']).to include(uri_show)
        expect(results['identifier_tesim']).to include(uri_thumb)
      end
    end
  end
end
