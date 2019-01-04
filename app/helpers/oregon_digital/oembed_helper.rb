# frozen_string_literal:true

module OregonDigital
  # Application wide helper to contain oembed methods
  module OembedHelper
    def assets_with_oembed
      @assets_with_oembed ||= OembedService.assets_with_oembed
    end

    def assets_with_errored_oembed
      @assets_with_errored_oembed ||= OembedService.assets_with_errored_oembed
    end
  end
end
