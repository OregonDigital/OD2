# frozen_string_literal:true

FactoryBot.define do
  factory :collection_type, class: Hyrax::CollectionType do
    sequence(:title) { |n| "title-#{n}" }
  end

  factory :user_collection_type, class: Hyrax::CollectionType do
    initialize_with { Hyrax::CollectionType.find_or_create_default_collection_type }
  end
  factory :oai_collection_type, class: Hyrax::CollectionType do
    initialize_with { Hyrax::CollectionType.find_or_create_by(title: 'OAI Set') }
  end
end
