# frozen_string_literal:true

FactoryBot.define do
  factory :oembed_error do
    sequence(:document_id) { |n| ["MyID-#{n}"] }
    oembed_errors { ['MyText'] }
  end
end
