# frozen_string_literal:true

FactoryBot.define do
  factory :image do
    sequence(:title) { |n| ["title-#{n}"] }
    sequence(:id) { |n| ["id#{n}"] }
    resource_type { 'MyType' }
    color_content { ['Color'] }
    color_space { ['RGB'] }
    height { '100' }
    orientation { ['Horizontal'] }
    photograph_orientation { 'west' }
    resolution { '72' }
    view { ['exterior'] }
    width { '200' }
  end
end
