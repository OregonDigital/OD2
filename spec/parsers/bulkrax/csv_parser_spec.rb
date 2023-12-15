# frozen_string_literal: true

require 'rails_helper'

module Bulkrax
  RSpec.describe CsvParser do
    subject(:parser) { described_class.new(exporter) }

    let(:exporter) { FactoryBot.create(:bulkrax_exporter_local_collection) }
    let(:work) { create(:generic, title: ['Kraken I have known'], local_collection_name: [local_coll], depositor: user.email, id: 'abcde4321') }
    let(:local_coll) { OregonDigital::ControlledVocabularies::LocalCollectionName.new(uri) }
    let(:uri) { 'http://opaquenamespace.org/ns/localCollectionName/mss_furby' }
    let(:user) { build(:user) }
    let(:entries) { [entry] }
    let(:entry) { build(:bulkrax_csv_entry_export) }

    before do
      allow(OregonDigital::Triplestore).to receive(:fetch).and_return(RDF::Graph.new)
      work.reload
    end

    describe 'current_records_for_export.each' do
      it 'returns records for local collection' do
        ids = []
        parser.current_records_for_export.each { |id| ids << id }
        expect(ids).to eq ['abcde4321']
      end
    end

    describe 'write_files' do
      before do
        allow(exporter).to receive(:entries).and_return(entries)
        allow(CSV).to receive(:open).and_return(csv)
        allow(parser).to receive(:setup_export_file).and_return('/banana/banana.csv')
        allow(csv).to receive(:<<)
        allow(parser).to receive(:headers).and_return([])
        allow(exporter).to receive(:exporter_export_path).and_return('/banana')
      end

      context 'when headers have not been created' do
        let(:csv) { double }

        it 'gets headers' do
          expect(parser).to receive(:group_headers)
          parser.write_files
        end
      end
    end

    describe 'group_headers' do
      let(:headers) { %w[title rights_statement resource_type identifier] }

      it 'supplies headers' do
        expect(parser.group_headers(entries)).to match_array headers
      end
    end
  end
end
