# frozen_string_literal: true

module Blacklight
  module Rendering
    # Rendering pipeline for limiting the number of values to display
    class MaxValues < AbstractStep
      def render
        return next_step(values) unless config.max_values

        next_step(values.take(max_value).push(max_value_label))
      end

      private

      def max_value
        config.max_values.is_a?(Integer) ? config.max_values : 5
      end

      def max_value_label
        config.max_values_label || 'more'
      end
    end
  end
end
