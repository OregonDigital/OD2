# frozen_string_literal:true

FactoryBot.define do
  factory :image do
    sequence(:title) { |n| ["title-#{n}"] }
    id { ::Noid::Rails::Service.new.minter.mint }
    rights_statement { ['http://rightsstatements.org/vocab/InC/1.0/'] }
    identifier { ['MyIdentifier'] }
    resource_type { 'MyType' }
    color_content { ['Color'] }
    orientation { ['Horizontal'] }
    photograph_orientation { 'west' }
    resolution { '72' }
    view { ['exterior'] }
  end
end
