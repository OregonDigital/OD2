# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe OregonDigital::TriplePoweredService do
  let(:service) { described_class.new }

  # TEST NO.1: Test to see if label are being able to fetch and format 'label$uri'
  describe '#fetch_all_labels' do
    before do
      allow(service).to receive(:fetch_labels_uris).with(['http://www.blah.com', 'http://www.blah2.com']).and_return(['label1$http://www.blah.com', 'label2$http://www.blah2.com'])
    end

    it 'returns labels for uri' do
      expect(service.fetch_all_labels(['http://www.blah.com', 'http://www.blah2.com'])).to eq 'label1$http://www.blah.com'
    end
  end
end
