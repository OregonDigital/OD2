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
      expect(raw_collections.collect(&:pid).sort.join(' ')).to eq('gifford osu-scarc')
    end

    it 'returns nine images' do
      expect(raw_images.length).to eq(9)
    end

    it 'returns nine filesets' do
      expect(raw_filesets.length).to eq(9)
    end

    it 'returns all our admin sets' do
      expected = 'admin_set/default nwcu oac ohs osu osu-scarc-admin uo uo-jsma uo-mc uo-scua'
      expect(raw_admin_sets.collect(&:pid).sort.join(' ')).to eq(expected)
    end

    it 'returns one file per TIFF' do
      files = finder.all_objects.select { |o| o.model == '<blob>' }
      expect(files.length).to eq(raw_images.length)
    end

    it 'categorizes assets properly' do
      pids = finder.assets.collect(&:pid).sort.join(' ')
      assets = raw_images + raw_filesets
      raw_asset_pids = assets.collect(&:pid).sort.join(' ')
      expect(pids).to eq(raw_asset_pids)
    end

    it 'categorizes all admin sets and collections as "collections"' do
      pids = finder.collections.collect(&:pid).sort.join(' ')
      colls = raw_admin_sets + raw_collections
      raw_pids = colls.collect(&:pid).sort.join(' ')
      expect(pids).to eq(raw_pids)
    end

    1.upto(9) do |i|
      describe "image #{i}" do
        let(:image) { raw_images[i - 1] }
        let(:access_control) { finder.by_pid[image.access_control_pids[0]] }

        it 'has one access control pid' do
          expect(image.access_control_pids.length).to eq(1)
        end

        it "'s access control object is Hydra::AccessControl" do
          expect(access_control.model).to eq('Hydra::AccessControl')
        end

        it "'s access control object has 11 child permissions objects" do
          expect(access_control.contains.length).to eq(11)
        end
      end
    end

    1.upto(9) do |i|
      describe "fileset #{i}" do
        let(:fileset) { raw_filesets[i - 1] }
        let(:access_control) { finder.by_pid[fileset.access_control_pids[0]] }

        it 'has one child' do
          expect(fileset.contains_pids.length).to eq(1)
        end

        it 'has a child that contains a blob' do
          child = finder.by_pid[fileset.contains_pids[0]]
          c2 = finder.by_pid[child.contains_pids[0]]
          expect(c2.model).to eq('<blob>')
        end

        it 'has one access control pid' do
          expect(fileset.access_control_pids.length).to eq(1)
        end

        it "'s access control object is Hydra::AccessControl" do
          expect(access_control.model).to eq('Hydra::AccessControl')
        end

        it "'s access control object has 11 child permissions objects" do
          expect(access_control.contains.length).to eq(11)
        end
      end
    end
  end
end
