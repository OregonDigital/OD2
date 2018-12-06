module Blacklight::Oembed
  class EmbedController < ActionController::Base

    def show
      render json: { html: get_embed_content(params[:url], additional_params) }
    end

    private

    def get_embed_content(url, add_params)
      begin
        OEmbed::Providers.get(url, **add_params).html.html_safe
      rescue OEmbed::NotFound
        response.status = 400
        ""
      end
    end

    ##
    # Allows for blacklight-oembed users to pass through additional configured
    # parameters
    def additional_params
      params
        .slice(*Blacklight::Oembed::Engine.config.additional_params)
        .to_unsafe_h
        .symbolize_keys
    end
  end
end
