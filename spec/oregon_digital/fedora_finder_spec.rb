# frozen_string_literal:true

# This is pretty awful, but this suite now exceeds one minute despite using
# VCR, because of how every rspec example reloads all setup data.  Though VCR
# records the HTTP traffic, it can't reduce the system's innate inefficiencies:
# reading the data for just 9 images across two collections requires ~350
# requests and responses, which turn into ActiveFedora object instantiations.
#
# After this hack, the suite runs in about five seconds.

RSpec.describe OregonDigital::FedoraFinder do
  describe '.fetch_all' do
    subject do
      VCR.configure do |c|
        c.hook_into :faraday
        c.cassette_library_dir = 'spec/cassettes'
        c.allow_http_connections_when_no_cassette = true
      end
      finder = described_class.new(ActiveFedora.fedora.base_uri)
      VCR.use_cassette('fedora-fetch', record: :none, erb: { fedora_uri: ActiveFedora.fedora.base_uri }) do
        finder.fetch_all
      end

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
        describe "fileset #{i}" do
          let(:fileset) { raw_filesets[i - 1] }

          it 'has one child' do
            expect(fileset.contains_pids.length).to eq(1)
          end

          it 'has a child that contains a blob' do
            child = finder.by_pid[fileset.contains_pids[0]]
            c2 = finder.by_pid[child.contains_pids[0]]
            expect(c2.model).to eq('<blob>')
          end
        end
      end

      1.upto(18) do |i|
        describe "asset #{i}" do
          let(:asset) { finder.assets[i - 1] }
          let(:access_control) { finder.by_pid[asset.access_control_pids[0]] }

          it 'is a FileSet or an Image' do
            expect(asset.model).to eq('Image').or eq('FileSet')
          end

          it 'has one access control pid' do
            expect(asset.access_control_pids.length).to eq(1)
          end

          it "'s access control object is Hydra::AccessControl" do
            expect(access_control.model).to eq('Hydra::AccessControl')
          end

          it "'s access control object has 11 child permissions" do
            children = access_control.contains_pids.collect { |pid| finder.by_pid[pid] }
            perms = children.select { |child| child.model == 'Hydra::AccessControls::Permission' }
            expect(perms.length).to eq(11)
          end
        end
      end
    end
  end
end
