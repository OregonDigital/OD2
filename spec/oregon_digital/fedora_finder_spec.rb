# frozen_string_literal:true

RSpec.describe OregonDigital::FedoraFinder do
  before do
    VCR.configure do |c|
      c.hook_into :faraday
      c.cassette_library_dir = 'spec/cassettes'
      c.allow_http_connections_when_no_cassette = true
    end
  end

  describe '.fetch_all' do
    before do
      VCR.use_cassette('fedora-fetch', record: :none) do
        finder.fetch_all
      end
    end

    let(:finder) { described_class.new(ActiveFedora.fedora.base_uri) }
    let(:raw_collections) { finder.all_objects.select { |o| o.model == 'Collection' } }
    let(:raw_images) { finder.all_objects.select { |o| o.model == 'Image' } }
    let(:raw_filesets) { finder.all_objects.select { |o| o.model == 'FileSet' } }
    let(:raw_admin_sets) { finder.all_objects.select { |o| o.model == 'AdminSet' } }

    it 'has the Gifford and OSU SCARC collections' do
      expect(raw_collections.collect { |c| c.pid }.sort.join(' ')).to eq('gifford osu-scarc')
    end

    it 'returns nine images' do
      expect(raw_images.length).to eq(9)
    end

    it 'returns all our admin sets' do
      expected = 'admin_set/default nwcu oac ohs osu osu-scarc-admin uo uo-jsma uo-mc uo-scua'
      expect(raw_admin_sets.collect { |as| as.pid }.sort.join(' ')).to eq(expected)
    end

    it 'returns one file per TIFF' do
      files = finder.all_objects.select { |o| o.model == '<blob>' }
      expect(files.length).to eq(raw_images.length)
    end

    it 'categorizes assets properly' do
      pids = finder.assets.collect {|o| o.pid }.sort.join(' ')
      assets = raw_images + raw_filesets
      raw_asset_pids = assets.collect {|o| o.pid }.sort.join(' ')
      expect(pids).to eq(raw_asset_pids)
    end

    it 'categorizes all admin sets and collections as "collections"' do
      pids = finder.collections.collect {|c| c.pid}.sort.join(' ')
      colls = raw_admin_sets + raw_collections
      raw_pids = colls.collect {|c| c.pid}.sort.join(' ')
      expect(pids).to eq(raw_pids)
    end
  end
end
