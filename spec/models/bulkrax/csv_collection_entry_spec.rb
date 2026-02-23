# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe CsvCollectionEntry, type: :model do
    subject(:entry) { described_class.new }

    let(:coll_id) { 'my-little-pony-coll' }
    let(:digital_collection_type) { create(:collection_type, machine_id: :digital_collection) }

    before do
      allow(Hyrax::CollectionType).to receive(:find).with(machine_id: 'digital_collection').and_return(digital_collection_type)
    end

    describe 'add_collection_type_gid' do
      context 'when updating a coll' do
        before do
          entry.parsed_metadata = { 'id' => coll_id }
          allow(Collection).to receive(:exists?).with(coll_id).and_return true
          entry.add_collection_type_gid
        end

        it 'suppresses collection_type_gid' do
          expect(entry.parsed_metadata.keys).not_to include 'collection_type_gid'
        end
      end

      context 'when creating a coll' do
        before do
          entry.parsed_metadata = {}
          entry.add_collection_type_gid
        end

        it 'adds collection_type_gid' do
          expect(entry.parsed_metadata.keys).to include 'collection_type_gid'
        end
      end
    end
  end
end
