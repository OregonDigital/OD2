module Blacklight::Oembed
  class EmbedController < ActionController::Base

    def show
      render json: { html: get_embed_content(params[:url], additional_params) }
    end

    private

    def get_embed_content(url, add_params)
      begin
        OEmbed::Providers.get(url, **add_params).html.html_safe
      rescue OEmbed::NotFound => e
        # Create OembedError for oEmbed Errors dashboard
        works = Generic.search_with_conditions(oembed_url: url)
        works.each do |work|
          errors = OembedError.find_or_create_by(document_id: work.id)
          errors.oembed_errors << e
          errors.save
        end

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
