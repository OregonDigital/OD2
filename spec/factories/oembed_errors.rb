# frozen_string_literal:true

FactoryBot.define do
  factory :oembed_error do
    document_id { ::Noid::Rails::Service.new.minter.mint }
    oembed_errors { ['MyText'] }
  end
end
