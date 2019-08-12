# frozen_string_literal:true

FactoryBot.define do
  factory :video do
    sequence(:title) { |n| ["title-#{n}"] }
    resource_type { 'MyType' }
    height { '100' }
    width { '200' }
  end
end
