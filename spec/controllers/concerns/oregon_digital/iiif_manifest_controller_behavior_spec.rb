# frozen_string_literal:true

# Dummy object implementing the required methods for the behavior mixin to work
class DummyController < ApplicationController
  include Hyrax::WorksControllerBehavior
  include Hyrax::BreadcrumbsForWorks
  include OregonDigital::IIIFManifestControllerBehavior
end

RSpec.describe OregonDigital::IIIFManifestControllerBehavior do
  let(:controller) { DummyController.new }

  describe '.manifest' do
    let(:headers) { {} }
    # This is a hash because I have no idea which class the manifest factory
    # actually returns, and rspec won't let me mock #to_h unless the instance
    # already supports it
    let(:manifest_builder) { {} }
    let(:hsh) { { foo: '1', bar: 2 } }
    let(:sanitized) { '{"foo": "1", "bar": 2}' }

    before do
      allow(controller).to receive(:headers).and_return(headers)
      allow(controller).to receive(:manifest_builder).and_return(manifest_builder)
      allow(manifest_builder).to receive(:to_h).and_return(hsh)
      allow(controller).to receive(:sanitize_manifest).and_return(sanitized)
      allow(controller).to receive(:respond_to).and_yield(OpenStruct.new(json: nil, html: nil))
    end

    it 'sets the Access-Control-Allow-Origin header' do
      expect(headers).to receive(:[]=).with('Access-Control-Allow-Origin', '*')
      controller.manifest
    end

    it 'sanitizes the IIIF manifest' do
      expect(controller).to receive(:sanitize_manifest).with(JSON.parse(hsh.to_json))
      controller.manifest
    end
  end

  describe '.jp2_work_presenter' do
    context 'when a work presenter is already cached' do
      let(:cached) { double }

      before do
        controller.instance_variable_set('@jp2_work_presenter', cached)
      end

      it "doesn't fetch a solr doc" do
        expect(controller).not_to receive(:search_result_document)
        controller.jp2_work_presenter
      end

      it "doesn't check the current ability" do
        expect(controller).not_to receive(:current_ability)
        controller.jp2_work_presenter
      end

      it 'returns the cached work presenter' do
        expect(controller.jp2_work_presenter).to eq(cached)
      end
    end

    context 'when a work presenter has not been cached' do
      let(:solrdoc) { instance_double('SolrDocument') }
      let(:hydra_model) { class_double('Image') }
      let(:asset) { instance_double('Image') }
      let(:ability) { instance_double('Ability') }
      let(:request) { instance_double('Request') }
      let(:file_sets) { [] }
      let(:id) { 'i am an id' }

      before do
        allow(controller).to receive(:params).and_return({})
        allow(controller).to receive(:search_result_document).and_return(solrdoc)
        allow(controller).to receive(:current_ability).and_return(ability)
        allow(solrdoc).to receive(:hydra_model).and_return(hydra_model)
        allow(hydra_model).to receive(:find).with(id).and_return(asset)
        allow(asset).to receive(:file_sets).and_return(file_sets)
        allow(solrdoc).to receive(:id).and_return(id)

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
