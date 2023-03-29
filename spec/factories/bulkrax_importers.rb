# frozen_string_literal: true

# from bulkrax, modified
FactoryBot.define do
  factory :bulkrax_importer_csv, class: 'Bulkrax::Importer' do
    name { 'CSV Import' }
    admin_set_id { 'osuo' }
    user { FactoryBot.build(:admin) }
    parser_klass { 'Bulkrax::CsvParser' }
    parser_fields { { 'import_file_path' => 'spec/fixtures/pna99999_1.csv' } }
    field_mapping { {} }
    after :create, &:current_run

    trait :with_relationships_mappings do
      field_mapping do
        {
          'parents' => { 'from' => ['parents'], split: /\s*[|]\s*/, related_parents_field_mapping: true },
          'children' => { 'from' => ['children'], split: /\s*[|]\s*/, related_children_field_mapping: true }
        }
      end
    end
  end
end
