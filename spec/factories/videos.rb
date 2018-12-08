# frozen_string_literal:true

FactoryBot.define do
  factory :video do
    sequence(:title) { |n| ["title-#{n}"] }
    height { '100' }
    width { '200' }
  end
end
