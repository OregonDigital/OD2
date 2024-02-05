# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe OregonDigital::TriplePoweredService do
  let(:service) { described_class.new }

  # TEST NO.1: Test to see if label are being able to fetch and format 'label$uri'
  describe '#fetch_all_labels' do
    before do
      allow(service).to receive(:fetch_from_store).with('http://www.blah.com').and_return(RDF::Graph.new)
      allow(service).to receive(:predicate_labels).with(RDF::Graph.new).and_return({ object1: ['label1'] })
    end

    it 'returns labels for uri' do
      expect(service.fetch_all_labels(['http://www.blah.com'])).to eq ['label1$http://www.blah.com']
    end
  end

  # TEST NO.2: Test to see if label are being able to fetch and format 'label$uri' with the date
  describe '#fetch_all_labels_with_date' do
    before do
      allow(service).to receive(:fetch_from_store).with('http://www.blah.com').and_return(RDF::Graph.new)
      allow(service).to receive(:predicate_labels).with(RDF::Graph.new).and_return({ object1: ['label1'] })
      allow(service).to receive(:predicate_label_dates).with(RDF::Graph.new).and_return({ object1: ['label1 - 1973/1976'] })
    end

    it 'returns labels for uri' do
      expect(service.fetch_all_labels_with_date(['http://www.blah.com'])).to eq ['label1 - 1973/1976$http://www.blah.com']
    end
  end

  # TEST NO.3: Test to see if label are being able to fetch and format 'label$uri' with multiple uris
  describe '#fetch_top_label' do
    before do
      allow(service).to receive(:fetch_all_labels).with(['http://www.blah.com', 'http://www.blah2.com']).and_return(['label1$http://www.blah.com', 'label2$http://www.blah2.com'])
    end

    it 'returns labels for uri' do
      expect(service.check_and_fetch_label(['http://www.blah.com', 'http://www.blah2.com'])).to eq 'label1$http://www.blah.com'
    end
  end
end
