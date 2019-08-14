# frozen_string_literal:true

FactoryBot.define do
  factory :video do
    sequence(:title) { |n| ["title-#{n}"] }
    sequence(:id) { |n| ["id-#{n}"] }
    resource_type { 'MyType' }
    height { '100' }
    width { '200' }
  end
end
