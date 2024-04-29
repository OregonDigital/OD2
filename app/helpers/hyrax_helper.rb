# frozen_string_literal:true

# Application wide helper to contain hyrax based methods
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include OregonDigital::HyraxHelperBehavior
  include OregonDigital::ContactFormHelper
  include OregonDigital::RenderConstraintsHelperBehavior

  # OVERRIDE FROM HYRAX. Adds in warning tab
  def form_tabs_for(form:)
    if form.instance_of? Hyrax::Forms::BatchUploadForm
      %w[files metadata relationships warning]
    else
      %w[metadata files relationships warning]
    end
  end
end
