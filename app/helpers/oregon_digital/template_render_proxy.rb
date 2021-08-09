# frozen_string_literal: true

module OregonDigital
  # Wrapper class for rendering work show templates through kaminari
  # Work show pages come in from the Hyrax routeset but is inside the oregon_digital namespace
  # So when a #url_for call is made against the controller/render stack, the Hyrax routeset is queried
  # and no route is found. main_app#url_for is supposed to be used instead.
  class TemplateRenderProxy
    def initialize(proxy)
      @proxy = proxy
      @params = proxy.params
    end

    attr_reader :params

    def url_for(*args, &block)
      main_app.send(:url_for, *args, &block)
    end

    # delegates view helper methods to @template
    def method_missing(name, *args, &block)
      @proxy.respond_to?(name, *args) ? @proxy.send(name, *args, &block) : super
    end

    def respond_to_missing?(name, *args)
      @proxy.respond_to?(name, *args) || super
    end
  end
end
