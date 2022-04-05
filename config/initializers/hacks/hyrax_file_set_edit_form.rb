# frozen_string_literal:true

Rails.application.config.to_prepare do
  Hyrax::Forms::FileSetEditForm.class_eval do
    # Add oembed_url to permited FileSet terms
    self.terms += [:oembed_url]
  end
end
