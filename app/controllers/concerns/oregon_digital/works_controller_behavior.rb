# frozen_string_literal:true

module OregonDigital
  # Behavior for each work type controller
  module WorksControllerBehavior

    # We can use Hyrax::WorksControllerBehavior definition and add on additional params we want
    def attributes_for_actor
      attributes = super
      oembed_urls = params.fetch(:oembed_urls, [])
      attributes[:oembed_urls] = oembed_urls

      attributes
    end
  end
end
