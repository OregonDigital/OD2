# frozen_string_literal:true

FactoryBot.define do
  factory :video do
    sequence(:title) { |n| ["title-#{n}"] }
    repository { OregonDigital::ControlledVocabularies::Repository.new('http://opaquenamespace.org/ns/repository/my/repo') }
    resource_type { 'MyType' }
    height { '100' }
    width { '200' }
  end
end
