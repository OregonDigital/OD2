# frozen_string_literal: true
module Hyrax
  # Injects a search builder filter to hide documents marked as suppressed
  module FilterTombstone
    extend ActiveSupport::Concern

    included do
      self.default_processor_chain += [:non_tombstoned_works]
    end

    def non_tombstoned_works(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << '-workflow_state_name_ssim:tombstoned'
    end
  end
end