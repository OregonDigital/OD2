# frozen_string_literal: true

# This class should NOT be generated into local app. If you generated
# into local app in a previous version, remove that, config is done
# in CatalogController now.
#
# Note that this NEEDS to sub-class CatalogController, so it gets any
# custom searching behavior you've added, and uses when fetching facets
# etc. It does that right now because BlacklightAdvancedSearch::AdvancedController
# is hard-coded to subclass CatalogController.
#
# TODO:
# This seperate controller may not need to exist at all -- it just exists
# to provide the advanced search form (and fetching of facets to display
# on that form). Instead, mix-in a new "advanced" action to CatalogController?
# (Make a backwards compat route though).
#
# Alternately, if this does exist as a seperate controller, it should
# _directly_ < CatalogController, and BlacklightAdvancedSearch::AdvancedController
# should be a mix-in that does not assume parent controller. Then, if you have
# multi-controllers, you just need to create new `AdvancedControllerForX < XController`
# which still mixes in BlacklightAdvancedSearch::AdvancedController. There
# are probably some other edges that need to be smoothed for that approach, but
# that'd be the direction.

class AdvancedController < BlacklightAdvancedSearch::AdvancedController
  copy_blacklight_config_from(CatalogController)

  configure_blacklight do |config|
    config.add_facet_field 'copyright_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.copyright_combined'), limit: -1
    config.add_facet_field 'file_format_sim', label: I18n.translate('simple_form.labels.defaults.file_format'), limit: -1
    config.add_facet_field 'resource_type_label_sim', label: I18n.translate('simple_form.labels.defaults.resource_type_label'), limit: -1
    config.add_facet_field 'topic_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.topic_combined'), limit: -1
    config.add_facet_field 'creator_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.creator_combined'), limit: -1
    config.add_facet_field 'date_combined_year_label_ssim', label: I18n.translate('simple_form.labels.defaults.date_year_combined'), limit: -1, range: { segments: false }, include_in_advanced_search: false
    config.add_facet_field 'date_combined_decade_label_ssim', label: I18n.translate('simple_form.labels.defaults.date_decade_combined'), limit: -1
    config.add_facet_field 'location_combined_label_sim', label: I18n.translate('simple_form.labels.defaults.location_combined'), limit: -1
    config.add_facet_field 'workType_label_sim', label: I18n.translate('simple_form.labels.defaults.workType'), limit: -1
    config.add_facet_field 'language_label_sim', label: I18n.translate('simple_form.labels.defaults.language'), limit: -1
    config.add_facet_field 'non_user_collections_ssim', limit: -1, label: 'Collection'
    config.add_facet_field 'institution_label_sim', limit: -1, label: 'Institution'
    config.add_facet_field 'full_size_download_allowed_label_sim', label: I18n.translate('simple_form.labels.defaults.full_size_download_allowed'), limit: -1
  end
end
