# frozen_string_literal: true

require 'rails_helper'
require 'bulkrax/entry_spec_helper'

RSpec.describe Bulkrax::ParserExportRecordSet do
  describe Bulkrax::ParserExportRecordSet::All do
    let(:works) do
      [
        SolrDocument.new(id: 1, file_set_ids_ssim: ['a']),
        SolrDocument.new(id: 2, file_set_ids_ssim: ['b']),
        SolrDocument.new(id: 3, file_set_ids_ssim: ['c']),
        SolrDocument.new(id: 4, file_set_ids_ssim: ['d']),
        SolrDocument.new(id: 5, file_set_ids_ssim: ['e']),
        SolrDocument.new(id: 6, file_set_ids_ssim: ['f'])
      ]
    end

    let(:file_sets) do
      [
        SolrDocument.new(id: 'a'),
        SolrDocument.new(id: 'b'),
        SolrDocument.new(id: 'c'),
        SolrDocument.new(id: 'd'),
        SolrDocument.new(id: 'e'),
        SolrDocument.new(id: 'f')
      ]
    end

    let(:collections) do
      [
        SolrDocument.new(id: 100),
        SolrDocument.new(id: 200)
      ]
    end
    let(:exporter) { Bulkrax::EntrySpecHelper.exporter_for(parser_class_name: 'Bulkrax::CsvParser', exporter_limit: limit) }
    let(:parser) { exporter.parser }

    let(:count_of_items) { 14 } # I hand calculated that based on the above

    let(:record_set) { described_class.new(parser: parser) }

    before do
      allow(record_set).to receive(:works).and_return(works)
      allow(record_set).to receive(:collections).and_return(collections)
      allow(record_set).to receive(:file_sets).and_return(file_sets)
    end

    describe '#in_groups_of' do
      # rubocop:disable RSpec/NestedGroups
      context 'when the number of items exceed the limit' do
        let(:limit) { 5 }

        it 'will return the limit' do
          expect { |block| record_set.in_groups_of(3, &block) }.to yield_successive_args(
            [[works[0].id, parser.entry_class.to_s],
             [works[1].id, parser.entry_class.to_s],
             [works[2].id, parser.entry_class.to_s]],
            [[works[3].id, parser.entry_class.to_s],
             [works[4].id, parser.entry_class.to_s]]
          )
        end
      end

      context 'when there is no limit' do
        let(:limit) { 0 }

        it 'will return all the items' do
          expect { |block| record_set.in_groups_of(3, &block) }.to yield_successive_args(
            [[works[0].id, parser.entry_class.to_s],
             [works[1].id, parser.entry_class.to_s],
             [works[2].id, parser.entry_class.to_s]],
            [[works[3].id, parser.entry_class.to_s],
             [works[4].id, parser.entry_class.to_s],
             [works[5].id, parser.entry_class.to_s]],
            [[collections[0].id, parser.collection_entry_class.to_s],
             [collections[1].id, parser.collection_entry_class.to_s]],
            [[file_sets[0].id, parser.file_set_entry_class.to_s],
             [file_sets[1].id, parser.file_set_entry_class.to_s],
             [file_sets[2].id, parser.file_set_entry_class.to_s]],
            [[file_sets[3].id, parser.file_set_entry_class.to_s],
             [file_sets[4].id, parser.file_set_entry_class.to_s],
             [file_sets[5].id, parser.file_set_entry_class.to_s]]
          )
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
