# frozen_string_literal:true

RSpec.describe OregonDigital::MP3Presenter do
  let(:file_set) { instance_double(FileSet, duration: ['0:00:02:30']) }
  let(:mp3_path) { 'file:///data/tmp/shared/derivatives/2v/23/vt/36/2-0001-mp3.mp3' }
  let(:label) { 'Page 2' }
  let(:ability) { instance_double(Ability) }
  let(:request) { OpenStruct.new(base_url: 'http://example.org') }
  let(:presenter) { described_class.new(file_set, mp3_path, label, ability, request) }
  let(:readable) { true }
  let(:video) { instance_double(IIIFManifest::V3::DisplayContent) }

  before do
    allow(ability).to receive(:can?).with(:read, file_set).and_return(readable)
    allow(IIIFManifest::V3::DisplayContent).to receive(:new).and_return(video)
  end

  describe '#display_content' do
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

      it 'creates a new IIIFManifest::Display video' do
        expect(IIIFManifest::V3::DisplayContent).to receive(:new).with(
          'foo', type: 'Audio', format: 'audio/mp3', duration: 3
        )
        presenter.display_content
      end

      it 'returns the IIIFManifest::Display video' do
        expect(presenter.display_content).to eq(video)
      end
    end
  end

  describe '#to_s' do
    it 'returns the #label value' do
      allow(presenter).to receive(:label).and_return('i am a label and a to_s')
      expect(presenter.to_s).to eq('i am a label and a to_s')
    end
  end

  describe '#default_content_path' do
    it 'returns the download path for an mp3 derivative' do
      expect(presenter.send(:default_content_path)).to eq(request.base_url + Hyrax::Engine.routes.url_helpers.download_path(file_set, file: 'mp3'))
    end
  end
end
