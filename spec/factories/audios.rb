# frozen_string_literal:true

FactoryBot.define do
  factory :audio do
    sequence(:title) { |n| ["title-#{n}"] }
    id { ::Noid::Rails::Service.new.minter.mint }
    resource_type { 'MyType' }
    rights_statement { ['http://rightsstatements.org/vocab/InC/1.0/'] }
    identifier { ['MyIdentifier'] }
  end
end
