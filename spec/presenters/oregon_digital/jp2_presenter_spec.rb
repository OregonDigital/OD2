# frozen_string_literal:true

RSpec.describe OregonDigital::JP2Presenter do
  let(:file_set) { instance_double(FileSet) }
  let(:jp2_path) { 'file:///data/tmp/shared/derivatives/2v/23/vt/36/2-0001-jp2.jp2' }
  let(:label) { 'Page 2' }
  let(:ability) { instance_double(Ability) }
  let(:request) { OpenStruct.new(base_url: 'http://example.org') }
  let(:presenter) { described_class.new(file_set, jp2_path, label, ability, request) }
  let(:readable) { true }
  let(:image) { instance_double(IIIFManifest::V3::DisplayContent) }

  before do
    allow(ability).to receive(:can?).with(:read, file_set).and_return(readable)
    allow(IIIFManifest::V3::DisplayContent).to receive(:new).and_return(image)
  end

  describe '#display_content' do
    let(:iiif_endpoint) { instance_double(IIIFManifest::IIIFEndpoint) }

    before do
      allow(presenter).to receive(:iiif_endpoint).and_return(iiif_endpoint)
    end

    context 'when user is not allowed to see it' do
      let(:readable) { false }

      it 'returns nil' do
        expect(IIIFManifest::V3::DisplayContent).not_to receive(:new)
        presenter.display_content
      end
    end

    context 'when user is allowed to see it' do
      before do
        allow(presenter).to receive(:default_content_path).and_return('foo')
      end

      it 'creates a new IIIFManifest::Display image' do
        expect(IIIFManifest::V3::DisplayContent).to receive(:new).with(
          'foo', type: 'Image', format: 'image/jpeg', width: 640, height: 480, iiif_endpoint: iiif_endpoint
        )
        presenter.display_content
      end

      it 'returns the IIIFManifest::Display image' do
        expect(presenter.display_content).to eq(image)
      end
    end
  end

  describe '#to_s' do
    it 'returns the #label value' do
      allow(presenter).to receive(:label).and_return('i am a label and a to_s')
      expect(presenter.to_s).to eq('i am a label and a to_s')
    end
  end

  describe '#iiif_id' do
    let(:derivative_service) { instance_double(OregonDigital::FileSetDerivativesService) }
    let(:jp2_path) { '/foo/bar/quux/12/34/56/7-jp2.jp2' }

    before do
      allow(OregonDigital::FileSetDerivativesService).to receive(:new).and_return(derivative_service)
      allow(derivative_service).to receive(:derivative_url).with('jp2').and_return('/foo/bar/quux/id-jp2.jp2')
    end

    it 'returns a URL-encoded version of the relative path to the image' do
      expect(presenter.send(:iiif_id)).to eq('12%2F34%2F56%2F7-jp2.jp2')
    end
  end

  describe '#iiif_url' do
    let(:env_url) { 'http://iiif.base' }
    let(:request_base_url) { 'http://request.base' }

    before do
      ENV['IIIF_SERVER_BASE_URL'] = env_url
      allow(request).to receive(:base_url).and_return(request_base_url)
      allow(presenter).to receive(:iiif_id).and_return('foo.jp2')
    end

    context 'when ENV is set up' do
      it 'uses the environment to determine base URL' do
        expect(presenter.send(:iiif_url)).to start_with(env_url)
      end
    end

    context 'when ENV is not set up' do
      it 'falls back on the request for its base URL' do
        ENV.delete('IIIF_SERVER_BASE_URL')
        expect(presenter.send(:iiif_url)).to start_with(request_base_url)
      end
    end

    it 'joins the base URL to the IIIF ID' do
      expect(presenter.send(:iiif_url)).to eq("http://iiif.base/#{presenter.send(:iiif_id)}")
    end
  end

  describe '#default_content_path' do
    it 'returns the IIIF path for a 640-wide jpg' do
      expect(presenter.send(:default_content_path)).to eq("#{presenter.send(:iiif_url)}/full/640,/0/default.jpg")
    end
  end

  describe '#iiif_endpoint' do
    let(:endpoint) { instance_double(IIIFManifest::IIIFEndpoint) }

    before do
      allow(IIIFManifest::IIIFEndpoint).to receive(:new).and_return(endpoint)
    end

    it 'returns the IIIFManifest endpoint instance' do
      expect(presenter.send(:iiif_endpoint)).to eq(endpoint)
    end
  end
end
