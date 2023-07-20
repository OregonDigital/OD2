# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bulkrax::CsvEntry, type: :model do
  let(:collection) { FactoryBot.build(:collection) }

  before do
    collection.id = 'octopi-i-have-known'
    collection.bulkrax_identifier = [collection.id]
    allow_any_instance_of(described_class).to receive(:collections_created?).and_return(true)
    allow_any_instance_of(described_class).to receive(:find_collection).and_return(collection)
  end

  describe 'builds entry' do
    let(:entry) { described_class.new(importerexporter: importer) }
    let(:importer) { FactoryBot.create(:bulkrax_importer_csv) }
    # no original_identifier field
    let(:data) do
      {
        model: 'image',
        identifier: 'pna_99999',
        title: 'Museum of Natural and Cultural History',
        subject: 'http://id.loc.gov/authorities/subjects/sh85006700|http://vocab.getty.edu/aat/300124515',
        resource_type: 'http://purl.org/dc/dcmitype/Image',
        rights_statement: 'http://rightsstatements.org/vocab/InC/1.0/',
        parents: collection.id
      }
    end

    context 'with required metadata' do
      let(:attribute) { { '0' => { id: 'http://id.loc.gov/authorities/subjects/sh85006700' } } }

      before do
        allow_any_instance_of(Bulkrax::ObjectFactory).to receive(:run!)
        allow(entry).to receive(:raw_metadata).and_return data.with_indifferent_access
      end

      it 'succeeds without original_identifier' do
        entry.build_metadata
        expect(entry.parsed_metadata['admin_set_id']).to eq 'osuo'
        expect(entry.parsed_metadata['subject_attributes'].size).to eq 2
        expect(entry.parsed_metadata['subject_attributes'].select { |k, _v| k == '0' }).to eq attribute
        expect(entry.parsed_metadata['parents']).to eq [collection.id]
      end
    end
  end

  # rubocop:disable RSpec/SubjectStub
  describe 'build_mapping_metadata' do
    subject(:entry) { described_class.new(importerexporter: exporter) }

    let(:exporter) { create(:bulkrax_exporter) }
    let(:hyrax_record) { build(:document, title: ['Frog and Toad Together']) }
    let(:mapping) do
      hash = {}
      hash['title'] = { from: ['http://purl.org/dc/terms/title'], split: true }
      hash['resource_type'] = { from: ['http://purl.org/dc/terms/type'] }
      hash['rights_statement'] = { from: ['http://www.europeana.edu/schemas/edm/rights'] }
      hash['identifier'] = { from: ['http://purl.org/dc/terms/identifier'], split: true }
      hash['first_line'] = { from: ['http://opaquenamespace.org/ns/sheetmusic_firstLine'] }
      hash
    end

    before do
      allow(entry).to receive(:fetch_field_mapping).and_return(mapping)
      allow(entry).to receive(:hyrax_record).and_return(hyrax_record)
    end

    it 'adds to the parsed_metadata without empty vals' do
      entry.parsed_metadata = {}
      entry.build_mapping_metadata
      expect(entry.parsed_metadata.keys).to include 'resource_type'
      expect(entry.parsed_metadata.keys).not_to include 'first_line'
    end
  end
  # rubocop:enable RSpec/SubjectStub
end
