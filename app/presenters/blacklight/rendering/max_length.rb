# frozen_string_literal: true

module Blacklight
  module Rendering
    # Rendering pipeline for truncating a field to a maxlength by word count
    class MaxLength < AbstractStep
      def render
        return next_step(values) unless config.truncate

        next_step(values.map { |x| x.truncate_words(truncate_length) })
      end

      private

      def truncate_length
        default = 20
        if config.truncate.is_a?(Hash)
          config.truncate[context.document_index_view_type] || default
        elsif config.truncate.is_a?(Integer)
          config.truncate
        else
          default
        end
      end
    end
  end
end
