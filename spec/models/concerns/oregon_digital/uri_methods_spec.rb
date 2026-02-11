# frozen_string_literal:true

class DummyClass
  include OregonDigital::UriMethods
end

RSpec.describe OregonDigital::UriMethods do
  let(:dummy) { DummyClass.new }
  let(:pid) { 'abcde1234' }
  let(:iiif) { ENV.fetch('IIIF_SERVER_BASE_URL') }
  let(:iiif_url) { iiif.ends_with?('/') ? iiif : iiif + '/' }
  let(:base) { Rails.application.routes.url_helpers.root_url }
  let(:base_url) { base.ends_with?('/') ? base : base + '/' }
  let(:correct_iiif_url) { iiif_url + 'ab/cd/e1/23/4-jp2.jp2/full/430,/0/default.jpg' }
  let(:correct_show_url) { base_url + 'concern/images/abcde1234' }
  let(:correct_iiif_doc_url) { iiif_url + 'ab/cd/e1/23/4-jp2-0000.jp2/full/430,/0/default.jpg' }
  let(:correct_video_url) { base_url + 'downloads/abcde1234?file=thumbnail' }

  describe 'iiif_server' do
    it 'ensures ending with slash' do
      expect(dummy.iiif_server).to end_with('iiif/')
    end
  end

  describe 'app_base_url' do
    it 'ensures ending with slash' do
      expect(dummy.app_base_url).to end_with('/')
    end
  end

  describe 'iiif_url' do
    it 'delivers correct url' do
      expect(dummy.iiif_url(pid)).to eq correct_iiif_url
    end
  end

  describe 'iiif_doc_url' do
    it 'delivers correct url' do
      expect(dummy.iiif_doc_url(pid)).to eq correct_iiif_doc_url
    end
  end

  describe 'show_url' do
    it 'delivers correct url' do
      expect(dummy.show_url('images', pid)).to eq correct_show_url
    end
  end

  describe 'video_thumb' do
    let(:doc) { SolrDocument.new(attributes) }
    let(:attributes) do
      {
        'id' => 'abcde1234',
        'has_model_ssim' => ['Video'],
        'thumbnail_path_ss' => '/downloads/abcde1234?file=thumbnail'
      }
    end

    before do
      allow(Hyrax::SolrService).to receive(:query).and_return([doc])
    end

    it 'delivers correct url' do
      expect(dummy.video_thumb(pid)).to eq correct_video_url
    end
  end
end
