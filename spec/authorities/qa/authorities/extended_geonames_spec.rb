# frozen_string_literal:true

RSpec.describe Qa::Authorities::ExtendedGeonames do
  let(:geonames_instance) { described_class.new }
  let(:response) { [{ 'geonames': [{ 'geonameId': 'myId', 'name': 'myName', 'adminName1': 'adminName1', 'countryName': 'countryName', 'fcl': 'A' }] }] }
  let(:label_hash) { { 'geonameId': 'myId', 'name': 'myName', 'adminName1': 'adminName1', 'countryName': 'countryName' } }
  let(:fcl) { 'Area' }

  it { expect(geonames_instance.label.call(label_hash, fcl)).to eq 'my_label' }
  describe "#search" do
    before do
      allow(geonames_instance).to receive(:json).with(:anything).and_return(response)
      allow(geonames_instance).to receive(:build_query_url).with('http://my.queryuri.com').and_return(response)
    end
    it { expect(geonames_instance.search('http://my.queryuri.com')).to eq [{ 'id': 'http://sws.geonames.org/myId/', 'label': 'name, adminName1, countryName, Area' }] }
  end
end
