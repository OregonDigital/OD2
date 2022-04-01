# frozen_string_literal: true

FactoryBot.define do
  factory :collection_representative do
    collection_id { 'MyString' }
    fileset_id { 'MyString' }
    order { 0 }
  end
end
