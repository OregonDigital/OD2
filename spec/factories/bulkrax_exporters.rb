# frozen_string_literal: true

FactoryBot.define do
  factory :bulkrax_exporter, class: 'Bulkrax::Exporter' do
    name { 'Export from Importer' }
    user { FactoryBot.build(:user) }
    export_type { 'metadata' }
    export_from { 'importer' }
    export_source { '1' }
    parser_klass { 'Bulkrax::CsvParser' }
    limit { 0 }
    field_mapping { Bulkrax.field_mappings['Bulkrax::CsvParser'] }
    generated_metadata { false }
  end

  factory :bulkrax_exporter_local_collection, class: 'Bulkrax::Exporter' do
    name { 'Export from Local Collection' }
    user { FactoryBot.build(:user) }
    export_type { 'metadata' }
    export_from { 'local_collection' }
    export_source { 'http://opaquenamespace.org/ns/localCollectionName/mss_furby' }
    parser_klass { 'Bulkrax::CsvParser' }
    limit { 0 }
    field_mapping { Bulkrax.field_mappings['Bulkrax::CsvParser'] }
    generated_metadata { false }
  end
end
