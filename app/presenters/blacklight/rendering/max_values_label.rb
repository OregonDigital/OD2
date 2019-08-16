# frozen_string_literal: true

module Blacklight
  module Rendering
    # Rendering pipeline for changing the last value label. Most useful when pared with MaxValues step
    class MaxValuesLabel < AbstractStep
      def render
        return next_step(values) unless config.max_values_label

        next_step(values.push(config.max_values_label))
      end
    end
  end
end
