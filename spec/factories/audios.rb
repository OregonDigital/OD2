# frozen_string_literal:true

FactoryBot.define do
  factory :audio do
    sequence(:title) { |n| ["title-#{n}"] }
  end
end
