# frozen_string_literal:true

Hyrax::BootstrapBreadcrumbsBuilder.class_eval do

  # Override breadcrumbs_options to set role to navigation
  def breadcrumbs_options
    { class: 'breadcrumb', role: "navigation", "aria-label" => "Breadcrumb" }
  end
end
