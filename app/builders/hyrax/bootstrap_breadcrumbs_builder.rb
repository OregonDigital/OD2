# frozen_string_literal: true

# OVERRIDE FROM HYRAX to allow breadcrumb of current page to be recognized
#
# The BootstrapBreadcrumbsBuilder is a Bootstrap compatible breadcrumb builder.
#
# It provides basic functionalities to render a breadcrumb navigation according to Bootstrap's conventions.
#
# BootstrapBreadcrumbsBuilder accepts a limited set of options:
#
# You can use it with the :builder option on render_breadcrumbs:
#     <%= render_breadcrumbs builder: Hyrax::BootstrapBreadcrumbsBuilder %>
#
class Hyrax::BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  include ActionView::Helpers::OutputSafetyHelper
  def render
    return '' if @elements.blank?

    @context.tag.nav(breadcrumbs_options) do
      @context.tag.ol do
        safe_join(@elements.uniq.collect { |e| render_element(e) })
      end
    end
  end

  def render_element(element)
    html_class = 'active' if @context.current_page?(compute_path(element)) || element.options['aria-current'] == 'page'
    element.options['aria-current'] = 'page' if html_class

    @context.tag.li(class: html_class) do
      @context.link_to(@context.truncate(compute_name(element), length: 30, separator: ' '), compute_path(element), element.options)
    end
  end

  def breadcrumbs_options
    { class: %i[breadcrumb col-sm-12], aria: { label: 'Navigation Breadcrumbs' } }
  end
end
