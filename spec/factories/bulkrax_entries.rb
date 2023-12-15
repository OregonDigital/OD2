# frozen_string_literal: true

FactoryBot.define do
  factory :bulkrax_csv_entry_work, class: 'Bulkrax::CsvEntry' do
    identifier { 'entry_work' }
    type { 'Bulkrax::CsvEntry' }
    importerexporter { FactoryBot.build(:bulkrax_importer) }
    raw_metadata { {} }
    parsed_metadata { {} }
  end

  factory :bulkrax_csv_entry_export, class: 'Bulkrax::CsvEntry' do
    identifier { 'csv_entry' }
    type { 'Bulkrax::CsvEntry' }
    importerexporter { FactoryBot.build(:bulkrax_exporter) }
    raw_metadata { {} }
    parsed_metadata { {
      'title' => 'Hiphopopotamus',
      'rights_statement' => 'http://rightsstatements.org/vocab/InC/1.0/',
      'resource_type' => 'http://purl.org/dc/dcmitype/Image',
      'identifier': 'abcde1234'
    } }
  end
end
