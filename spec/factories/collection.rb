# frozen_string_literal:true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| ["title-#{n}"] }
  end
end
