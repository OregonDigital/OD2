# frozen_string_literal: true
module Hyrax
  module Workflow
    module SwapVisibilityToPrivate
      def self.call(target:, **)
        model = ActiveFedora::Base.find(target.id)
        OregonDigital::SwapVisibilityJob.perform_later(model, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE)
      end
    end
  end
end
