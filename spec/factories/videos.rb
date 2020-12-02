# frozen_string_literal:true

FactoryBot.define do
  factory :video do
    sequence(:title) { |n| ["title-#{n}"] }
    id { ::Noid::Rails::Service.new.minter.mint }
    rights_statement { ['http://rightsstatements.org/vocab/InC/1.0/'] }
    identifier { ['MyIdentifier'] }
    resource_type { 'MyType' }
    height { '100' }
    width { '200' }
  end
end
