# frozen_string_literal: true

FactoryBot.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    user
    file { File.open('spec/fixtures/test.jpg') }
  end
end
