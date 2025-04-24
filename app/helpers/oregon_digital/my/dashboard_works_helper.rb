# frozen_string_literal: true

module OregonDigital
  module My
    # MODULE: A custom works dashboard helper for display filter works
    module DashboardWorksHelper
      # METHOD: Create a method to change the display value for the workflow state
      def workflow_state_display(value)
        {
          'deposited' => 'Published',
          'pending_review' => 'Under Review',
          'tombstoned' => 'Tombstoned'
        }[value] || value.titleize # Fallback to titleized value
      end
    end
  end
end
