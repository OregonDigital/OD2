# frozen_string_literal:true

FactoryBot.define do
  factory :collection do
    sequence(:title) { |n| ["title-#{n}"] }
    id { ::Noid::Rails::Service.new.minter.mint }
  end
end
