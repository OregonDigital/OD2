# frozen_string_literal: true

module Hyrax
  module Workflow
    # Hooked into workflow actions. When a work is tombstoned it runs this module and swaps the visibility to private
    module SwapVisibilityToPrivate
      def self.call(target:, **)
        model = ActiveFedora::Base.find(target.id)
        OregonDigital::SwapVisibilityJob.perform_later(model, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE)
      end
    end
  end
end
