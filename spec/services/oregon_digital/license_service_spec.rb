# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'
describe OregonDigital::LicenseService do
  let(:service) { described_class.new }

  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('http://creativecommons.org/licenses/by/3.0/us/')).to eq ['Attribution 3.0 United States']
    end
  end
end
