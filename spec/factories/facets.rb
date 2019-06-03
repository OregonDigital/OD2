# frozen_string_literal:true

FactoryBot.define do
  factory :facet do
    label { 'MyString' }
    solr_name { 'MyString' }
    collection_id { nil }
  end
end
