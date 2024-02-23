# frozen_string_literal: true

module Hyrax
  module Workflow
    # Removes work that has been tombstoned from collection featured filesets
    class RemoveFeaturedFileSets
      def self.call(target:, **)
        OregonDigital::RemoveFeaturedFileSetsJob.perform_later(target)
      end
    end
  end
end
