# frozen_string_literal:true

FactoryBot.define do
  factory :document do
    sequence(:title) { |n| ["title-#{n}"] }
    sequence(:id) { |n| ["id-#{n}"] }
    resource_type { 'MyType' }
  end
end
