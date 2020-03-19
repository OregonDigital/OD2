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

    # This may need some explanation: basically the Finder code deliberately
    # skips trying to parse anything with a 406 return, because those objects
    # don't have any JSON.  The only time this happens is when the requested
    # object is some kind of bitstream, which happens for an object's files.
    # These objects are still part of the request/response cycle when querying
    # Fedora, so it's worth testing for them so it's clear what's going on.
    it 'returns one model-free asset per TIFF' do
      files = objects.select { |o| o.model == '' }
      expect(files.length).to eq(images.length)
    end
  end
end
