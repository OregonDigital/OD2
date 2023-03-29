# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe CsvEntry, type: :model do
    let(:collection) { FactoryBot.build(:collection) }

    before do
      collection.id = 'octopi-i-have-known'
      collection.bulkrax_identifier = [collection.id]
      allow_any_instance_of(described_class).to receive(:collections_created?).and_return(true)
      allow_any_instance_of(described_class).to receive(:find_collection).and_return(collection)
    end

    describe 'builds entry' do
      let(:entry) { described_class.new(importerexporter: importer) }
      let(:importer) { FactoryBot.create(:bulkrax_importer_csv, :with_relationships_mappings) }
      # no original_identifier field
      let(:data) do
        {
          model: 'image',
          identifier: 'pna_99999',
          title: 'Museum of Natural and Cultural History',
          subject: 'http://id.loc.gov/authorities/subjects/sh85006700',
          resource_type: 'http://purl.org/dc/dcmitype/Image',
          rights_statement: 'http://rightsstatements.org/vocab/InC/1.0/',
          parents: collection.id
        }
      end

      context 'with required metadata' do
        let(:attribute) { { '0' => { id: 'http://id.loc.gov/authorities/subjects/sh85006700' } } }

        before do
          allow_any_instance_of(ObjectFactory).to receive(:run!)
          allow(entry).to receive(:raw_metadata).and_return data.with_indifferent_access
        end

        it 'succeeds without original_identifier' do
          entry.build
          expect(entry.status).to eq('Complete')
          expect(entry.parsed_metadata['admin_set_id']).to eq 'osuo'
          expect(entry.parsed_metadata['subject_attributes']).to eq attribute
          expect(entry.parsed_metadata['parents']).to eq [collection.id]
        end
      end
    end
  end
end
