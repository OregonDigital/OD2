# frozen_string_literal: true

module Blacklight
  module Rendering
    # Rendering pipeline for limiting the number of values to display
    class MaxValues < AbstractStep
      def render
        return next_step(values) unless config.max_values
        max_values = (config.max_values.is_a? Integer) ? config.max_values : 5
        max_values_label = config.max_values_label || 'more'
        next_step(values.take(max_values).push(max_values_label))
      end
    end
  end
end
