# frozen_string_literal:true

FactoryBot.define do
  factory :generic do
    sequence(:title) { |n| ["title-#{n}"] }
    resource_type { 'MyType' }
    repository { OregonDigital::ControlledVocabularies::Repository.new('http://opaquenamespace.org/ns/repository/my/repo') }
  end
end
