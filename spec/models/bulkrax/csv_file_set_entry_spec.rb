# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe CsvFileSetEntry, type: :model do
    subject(:entry) { described_class.new }

    describe '#validate_presence_of_parent!' do
      context 'when file_set is being updated' do
        before do
          entry.parsed_metadata = { 'id' => 'f012345abcd' }
          allow(entry).to receive(:related_parents_parsed_mapping).and_return('parents')
        end

        it 'passes' do
          # entry.validate_presence_of_parent!
          expect(entry.validate_presence_of_parent!).to eq true
        end
      end
    end

    describe '#validate_presence_of_filename!' do
      context 'when file_set is being updated' do
        before do
          entry.parsed_metadata = { 'id' => 'f012345abcd' }
        end

        it 'passes' do
          expect(entry.validate_presence_of_filename!).to eq true
        end
      end
    end
  end
end
