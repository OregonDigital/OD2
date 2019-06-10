# frozen_string_literal:true

FactoryBot.define do
  factory :video do
    sequence(:title) { |n| ["title-#{n}"] }
    sequence(:resource_type) { |n| "resource_type-#{n}" }
    height { '100' }
    width { '200' }
  end
end
