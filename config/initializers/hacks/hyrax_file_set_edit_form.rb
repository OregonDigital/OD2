# frozen_string_literal:true

Hyrax::Forms::FileSetEditForm.class_eval do
  # Add oembed_url to permited FileSet terms
  self.terms += [:oembed_url]
end
