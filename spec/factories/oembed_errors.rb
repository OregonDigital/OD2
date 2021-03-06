# frozen_string_literal:true

FactoryBot.define do
  factory :oembed_error do
    document_id { create(:work).id }
    oembed_errors { ['MyText'] }
  end
end
