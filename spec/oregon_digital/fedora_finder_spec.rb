# frozen_string_literal:true

RSpec.describe OregonDigital::FedoraFinder do
  before do
    VCR.configure do |c|
      c.hook_into :faraday
      c.cassette_library_dir = 'spec/cassettes'
      c.allow_http_connections_when_no_cassette = true
    end
  end

  let(:objects) do
    o = nil
    VCR.use_cassette('fedora-fetch', record: :none) do
      o = described_class.new(ActiveFedora.fedora.base_uri).fetch_all
    end

    o
  end

  describe '.fetch_all' do
    let(:collections) { objects.select { |o| o.model == 'Collection' } }
    let(:images) { objects.select { |o| o.model == 'Image' } }
    let(:admin_sets) { objects.select { |o| o.model == 'AdminSet' } }

    it 'has two collections' do
      expect(collections.length).to eq(2)
    end

    it 'has the Gifford and OSU SCARC collections' do
      expect(collections.collect { |c| c.pid }.sort.join(' ')).to eq('gifford osu-scarc')
    end

    it 'returns nine images' do
      expect(images.length).to eq(9)
    end

    it 'returns all our admin sets' do
      expected = 'admin_set/default nwcu oac ohs osu osu-scarc-admin uo uo-jsma uo-mc uo-scua'
      expect(admin_sets.collect { |as| as.pid }.sort.join(' ')).to eq(expected)
    end

    it 'returns one file per TIFF' do
      files = objects.select { |o| o.model == '<blob>' }
      expect(files.length).to eq(images.length)
    end
  end
end
