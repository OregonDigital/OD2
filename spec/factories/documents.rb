# frozen_string_literal:true

FactoryBot.define do
  factory :document do
    sequence(:title) { |n| ["title-#{n}"] }
    id { ::Noid::Rails::Service.new.minter.mint }
    resource_type { 'MyType' }
  end
end
