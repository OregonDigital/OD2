# frozen_string_literal: true

module Blacklight
  module Rendering
    # Rendering pipeline for truncating a field to a maxlength by word count
    class MaxLength < AbstractStep
      def render
        return next_step(values) unless config.truncate

        truncate_length = config.truncate.is_a?(Integer) ? config.truncate : 20
        next_step(values.map { |x| x.truncate_words(truncate_length) })
      end
    end
  end
end
