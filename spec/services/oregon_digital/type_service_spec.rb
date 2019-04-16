# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'
describe OregonDigital::TyoeService do
  let(:service) { described_class.new }

  describe '#all_labels' do
    it 'returns active terms' do
      expect(service.all_labels('http://purl.org/dc/dcmitype/Collection')).to eq ['Complex Object']
    end
  end
end
