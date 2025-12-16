# frozen_string_literal: true

require 'rails_helper'
require 'bulkrax/entry_spec_helper'

RSpec.describe Bulkrax::ParserExportRecordSet::ImporterWithFileSet do
  let(:importer_set) { described_class.new(parser: exporter.parser) }
  let(:exporter) { Bulkrax::EntrySpecHelper.exporter_for(parser_class_name: 'Bulkrax::CsvParser', exporter_limit: 10, export_source: '987', export_from: 'importer') }

  before do
    allow(importer_set).to receive(:work_docs).and_return([{ 'id' => 'abcde1234', 'member_ids_ssim' => ['f0abcde1234'] }])
    allow(Bulkrax.object_factory).to receive(:query).and_return([{ 'id' => 'f0abcde1234' }])
  end

  describe 'candidate_file_set_ids' do
    it 'returns an array of file set ids' do
      expect(importer_set.candidate_file_set_ids).to eq(['f0abcde1234'])
    end
  end

  describe 'work_ids' do
    it 'returns just the work ids' do
      expect(importer_set.work_ids).to eq(['abcde1234'])
    end
  end

  describe 'works' do
    it 'returns an array of works' do
      expect(importer_set.works).to eq([{ 'id' => 'abcde1234' }])
    end
  end

  describe 'file_sets' do
    it 'returns an array of filesets' do
      expect(importer_set.file_sets).to eq([{ 'id' => 'f0abcde1234' }])
    end
  end
end
