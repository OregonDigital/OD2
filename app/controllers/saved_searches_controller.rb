# frozen_string_literal: true

# Controller for saved searches provided by blacklight_advanced_search
class SavedSearchesController < ApplicationController
  include Blacklight::SavedSearches

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
