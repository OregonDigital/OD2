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
  end
end
