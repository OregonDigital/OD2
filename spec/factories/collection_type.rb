# frozen_string_literal:true

FactoryBot.define do
  factory :collection_type, class: Hyrax::CollectionType do
    sequence(:title) { |n| "title-#{n}" }
  end
end
