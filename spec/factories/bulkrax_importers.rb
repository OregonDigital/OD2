# frozen_string_literal: true

# from bulkrax, modified
FactoryBot.define do
  factory :bulkrax_importer_csv, class: 'Bulkrax::Importer' do
    name { 'CSV Import' }
    admin_set_id { 'osuo' }
    user { FactoryBot.build(:user) }
    parser_klass { 'Bulkrax::CsvParser' }
    parser_fields { { 'import_file_path' => 'spec/fixtures/pna99999_1.csv' } }
    field_mapping { Bulkrax.field_mappings['Bulkrax::CsvParser'] }
    after :create, &:current_run
  end
end
