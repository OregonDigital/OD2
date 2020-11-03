# frozen_string_literal: true

# Controller for search history provided by blacklight_advanced_search
class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
