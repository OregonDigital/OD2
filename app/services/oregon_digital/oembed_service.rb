# frozen_string_literal:true

module OregonDigital
  class OembedService < Hyrax::RestrictionService
    class << self
      #
      # Methods for Querying Repository to find Objects with oEmbed content
      #

      # Returns all assets with oEmbed URL set
      def assets_with_oembed
        builder = OregonDigital::OembedSearchBuilder.new(self)
        presenters(builder)
      end

      # Returns all assets with oEmbed URL set which have reported an error
      def assets_with_errored_oembed
        builder = OregonDigital::ErroredOembedSearchBuilder.new(self)
        presenters(builder)
      end

      private

      def presenter_class
        OregonDigital::OembedPresenter
      end
    end
  end
end
