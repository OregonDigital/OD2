# frozen_string_literal:true

RSpec.describe Qa::Authorities::ExtendedGeonames do
  let(:geonames_instance) { described_class.new }
  let(:response) { { 'geonames': [{ 'geonameId': 'myId', 'name': 'myName', 'adminName1': 'adminName1', 'countryName': 'countryName', 'fcl': 'A' }.with_indifferent_access] }.with_indifferent_access }
  let(:label_hash) { { geonameId: 'myId', name: 'myName', adminName1: 'adminName1', countryName: 'countryName' }.with_indifferent_access }
  let(:fcl) { 'Area' }

  it { expect(geonames_instance.label.call(label_hash, fcl)).to eq 'myName, adminName1, countryName, (Area)' }
  describe '#search' do
    before do
      allow(geonames_instance).to receive(:json).with(anything).and_return(response)
      allow(geonames_instance).to receive(:build_query_url).with('http://my.queryuri.com').and_return(response)
    end
    it { expect(geonames_instance.search('http://my.queryuri.com')).to eq [{ 'id': 'http://sws.geonames.org/myId/', 'label': 'myName, adminName1, countryName, (Administrative Boundary)' }.with_indifferent_access] }
  end
end
