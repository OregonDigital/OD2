# frozen_string_literal:true

FactoryBot.define do
  factory :generic do
    sequence(:title) { |n| ["title-#{n}"] }
    sequence(:id) { |n| ["id-#{n}"] }
    resource_type { 'MyType' }
  end
end
