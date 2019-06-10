# frozen_string_literal:true

FactoryBot.define do
  factory :audio do
    sequence(:title) { |n| ["title-#{n}"] }
    sequence(:resource_type) { |n| "resource_type-#{n}" }
  end
end
