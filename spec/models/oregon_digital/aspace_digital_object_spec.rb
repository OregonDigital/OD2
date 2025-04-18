# frozen_string_literal:true

require 'uri'
RSpec.describe OregonDigital::AspaceDigitalObject do
  let(:ado) { described_class.new('abcde1234') }
  let(:solrdoc) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'id' => 'abcde1234',
      'date_tesim' => ['1920s'],
      'archival_object_id_tesim' => ["['archival_objects/1234']"],
      'visibility_ssi' => 'open',
      'has_model_ssim' => ['Generic']
    }
  end
  let(:childdoc) { SolrDocument.new(attributes2) }
  let(:attributes2) do
    {
      'id' => 'abcde2345',
      'has_model_ssim' => ['Image'],
      'member_ids_ssim' => ['f0abcde2345']
    }
  end

  before do
    allow(SolrDocument).to receive(:find).with('abcde1234').and_return(solrdoc)
    allow(SolrDocument).to receive(:find).with('abcde2345').and_return(childdoc)
    allow(ado.doc).to receive(:ordered_member_ids).and_return(['abcde2345'])
  end

  describe 'add_date' do
    let(:resp) { {} }

    it 'returns empty hash instead of invalid date' do
      expect(ado.add_date).to eq resp
    end
  end

  describe 'linked_instance' do
    let(:resp) { { 'ref' => '/repositories/2/archival_objects/1234' } }

    it 'returns path with correct id' do
      expect(ado.linked_instance).to eq resp
    end
  end

  describe 'file_versions' do
    let(:iiif) { ENV.fetch('IIIF_SERVER_BASE_URL', 'http://localhost:3000') }
    let(:base) { Rails.application.routes.url_helpers.root_url }
    let(:resp) do
      [{
        'file_uri' => URI.join(iiif, 'f0/ab/cd/e2/34/5-jp2.jp2/full/430,/0/default.jpg').to_s,
        'is_representative' => true,
        'publish' => true,
        'use_statement' => 'image-thumbnail',
        'xlink_actuate_attribute' => 'onLoad',
        'xlink_show_attribute' => 'embed'
      },
       {
         'file_uri' => URI.join(base, 'concern/generics/abcde1234').to_s,
         'is_representative' => false,
         'publish' => true,
         'use_statement' => 'image-service',
         'xlink_actuate_attribute' => 'onRequest',
         'xlink_show_attribute' => 'new'
       }]
    end

    it 'returns an array of file metadata' do
      expect(ado.file_versions).to eq(resp)
    end
  end
end
