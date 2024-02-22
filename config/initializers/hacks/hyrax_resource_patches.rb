# frozen_string_literal:true

Rails.application.config.to_prepare do
  Hyrax::Resource.class_eval do
    include OregonDigital::Errors
  end
end
