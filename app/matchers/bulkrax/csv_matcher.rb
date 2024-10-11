# frozen_string_literal: true

module Bulkrax
  # adds parse methods
  # note that the field also needs to be added to list, see the override for ApplicationMatcher
  class CsvMatcher < ApplicationMatcher
    def parse_full_size_download_allowed(src)
      src.to_i
    end
  end
end
