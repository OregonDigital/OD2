module OregonDigital
  module OembedHelper
    def assets_with_oembed
      @assets_with_oembed ||= OembedService.assets_with_oembed
    end
  end
end
