# frozen_string_literal:true

FactoryBot.define do
  factory :document do
    sequence(:title) { |n| ["title-#{n}"] }
  end
end
