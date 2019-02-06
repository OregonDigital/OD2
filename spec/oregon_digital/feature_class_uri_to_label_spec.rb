# frozen_string_literal: true

RSpec.describe OregonDigital::FeatureClassUriToLabel do
  let(:converter) { described_class.new }
  let(:uri) { 'http://www.geonames.org/ontology#A' }

  it { expect(converter.uri_to_label(uri)).to eq 'Administrative Boundary' }
end
