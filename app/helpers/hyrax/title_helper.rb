# frozen_string_literal: true

# Module used to generate tab labels for browsers
module Hyrax::TitleHelper
  def application_name
    t('hyrax.product_name', default: super)
  end

  def construct_page_title(*elements)
    (elements.flatten.compact + [application_name]).join(' | ')
  end

  ##
  # @deprecated
  def curation_concern_page_title(curation_concern)
    Deprecation.warn 'The curation_concern_page_title helper will be removed in Hyrax 4.0.' \
      "\n\tUse title_presenter(curation_concern).page_title instead."
    title_presenter(curation_concern).page_title
  end

  def default_page_title
    if controller_name.singularize.titleize == 'Advanced'
      construct_page_title('Advanced Search')
    else
      construct_page_title(controller_name.singularize.titleize)
    end
  end

  def title_presenter(resource)
    Hyrax::PageTitleDecorator.new(resource)
  end
end
