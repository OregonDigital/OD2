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
        default = 5
        if config.max_value.is_a?(Hash)
          config.max_value[context.document_index_view_type] || default
        elsif config.max_values.is_a?(Integer)
          config.max_values
        else
          default
        end
      end

      def max_value_label
        config.max_values_label || 'more'
      end
    end
  end
end
