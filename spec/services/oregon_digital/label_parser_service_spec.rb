# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe OregonDigital::LabelParserService do
  # TEST NO.1: Parse out the label and uris
  describe '#parse_label_uris' do
    context 'when label includes a special character $' do
      let(:labels) { ['label1 the cost is $200.00$www.test.com', '$100.00$www.test.com'] }

      it 'returns a hash of label and uri from a label$uri pair' do
        expect(described_class.parse_label_uris(labels)).to eq [{ 'label' => 'label1 the cost is $200.00', 'uri' => 'www.test.com' }, { 'label' => '$100.00', 'uri' => 'www.test.com' }]
      end
    end

    context 'when label does not include a special character $' do
      let(:labels) { ['label1 the cost is 200.00 www.test.com', '100.00 www.test.com'] }

      it 'returns a hash of label and uri from a label$uri pair' do
        expect(described_class.parse_label_uris(labels)).to eq [{ 'label' => 'label1', 'uri' => 'www.test.com' }, { 'label' => 'label2', 'uri' => 'www.test.com' }]
      end
    end
  end

  # TEST NO.2: Parse out the labels only
  describe '#parse_labels' do
    context 'when get only the label' do
      let(:labels) { ['label1$www.test.com', 'label2$www.test.com'] }

      it 'returns only a list of labels' do
        expect(described_class.parse_labels(labels)).to eq %w[label1 label2]
      end
    end
  end

  # TEST NO.3: Test on no label present
  describe '#no_labels' do
    context 'with no labels supplied' do
      let(:labels) { nil }

      it 'returns an empty array of parsed labels' do
        expect(described_class.parse_labels(labels)).to eq []
      end
    end
  end
end
