# frozen_string_literal:true

require 'iiif_manifest'

RSpec.describe OregonDigital::IiifManifestV2Controller do
  # only the tests for authorization etc are new
  # the rest are from iiif_manifest_controller_behavior
  describe 'show' do
    let(:headers) { {} }
    let(:manifest_builder) { {} }
    let(:hsh) { { foo: '1', bar: 2 } }
    let(:sanitized) { '{"foo": "1", "bar": 2}' }
    let(:id) { 'abcde1234' }
    let(:solrdoc) { instance_double(SolrDocument, { id: id, hydra_model: Image }) }
    let(:ability) { double }

    before do
      allow(SolrDocument).to receive(:find).and_return(solrdoc)
      allow(controller).to receive(:current_ability).and_return(ability)
      allow(ability).to receive(:can?).with(:read, solrdoc).and_return(true)
      allow(controller).to receive(:headers).and_return(headers)
      allow(controller).to receive(:manifest_builder).and_return(manifest_builder)
      allow(manifest_builder).to receive(:to_h).and_return(hsh)
      allow(controller).to receive(:sanitize_manifest).and_return(sanitized)
      allow(controller).to receive(:respond_to).and_yield(OpenStruct.new(json: nil, html: nil))
    end

    it 'sets the Access-Control-Allow-Origin header' do
      expect(headers).to receive(:[]=).with('Access-Control-Allow-Origin', '*')
      get :show, params: { format: :json, id: id }
    end

    it 'sanitizes the IIIF manifest' do
      expect(controller).to receive(:sanitize_manifest).with(JSON.parse(hsh.to_json))
      get :show, params: { format: :json, id: id }
    end
  end

  context 'with unauthorized resource' do
    let(:solrdoc) { instance_double(SolrDocument, id: id) }
    let(:ability) { instance_double(Ability) }
    let(:id) { 'abcde1234' }

    before do
      allow(controller).to receive(:current_ability).and_return(ability)
      allow(ability).to receive(:can?).with(:read, solrdoc).and_return(false)
      allow(SolrDocument).to receive(:find).and_return(solrdoc)
      get :show, params: { format: :json, id: id }
    end

    it 'is unauthorized' do
      expect(controller.response).to have_http_status(:unauthorized)
      expect(controller.response.body).to include("access to #{id} not authorized")
    end
  end

  context 'with a resource not found' do
    let(:id) { 'abcde1234' }

    before do
      allow(SolrDocument).to receive(:find).and_raise(Blacklight::Exceptions::RecordNotFound)
      get :show, params: { format: :json, id: id }
    end

    it 'is not found' do
      expect(controller.response).to have_http_status(:not_found)
      expect(controller.response.body).to include("id '#{id}' not found")
    end
  end

  context 'with a non-image resource' do
    let(:solrdoc) { instance_double(SolrDocument, { id: id, hydra_model: Generic }) }
    let(:ability) { instance_double(Ability) }
    let(:id) { 'abcde1234' }

    before do
      allow(controller).to receive(:current_ability).and_return(ability)
      allow(ability).to receive(:can?).with(:read, solrdoc).and_return(true)
      allow(SolrDocument).to receive(:find).and_return(solrdoc)
      get :show, params: { format: :json, id: id }
    end

    it 'is not processed' do
      expect(controller.response).to have_http_status(:unprocessable_entity)
      expect(controller.response.body).to include("manifest not supported for #{id}")
    end
  end

  describe '.jp2_work_presenter' do
    context 'when a work presenter has not been cached' do
      let(:solrdoc) { instance_double('SolrDocument') }
      let(:work) { instance_double('Image') }
      let(:ability) { instance_double('Ability') }
      let(:request) { instance_double('Request') }
      let(:file_sets) { [] }
      let(:id) { 'i am an id' }

      before do
        allow(controller).to receive(:params).and_return({ id: id })
        allow(controller).to receive(:work).and_return(work)
        allow(controller).to receive(:current_ability).and_return(ability)
        allow(work).to receive(:file_sets).and_return(file_sets)
        allow(solrdoc).to receive(:id).and_return(id)
        controller.instance_variable_set('@solrdoc', solrdoc)
        controller.instance_variable_set('@jp2_work_presenter', nil)
      end

      it 'returns a new IIIF presenter' do
        expect(controller.jp2_work_presenter).to be_kind_of(OregonDigital::IIIFPresenter)
      end

      it "assigns the asset's file sets to the presenter" do
        expect(controller.jp2_work_presenter.file_sets).to eq(file_sets)
      end
    end
  end

  # sanitize_manifest was copied as-is from Hyrax, and has no documentation or
  # testing there, and makes little sense to me, so this test is basically
  # validating that it doesn't crash.
  describe '.sanitize_manifest(hash)' do
    let(:h) do
      {
        'description' => %w[foo bar],
        'label' => 'baz',
        'sequences' => [
          { 'canvases' => [{ 'label' => 'blah' }, { 'label' => 'blah 2' }] },
          { 'canvases' => [{ 'label' => 'seriously, blah' }] }
        ]
      }
    end

    it 'works' do
      controller.sanitize_manifest(h)
    end
  end
end
