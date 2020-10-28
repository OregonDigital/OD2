# frozen_string_literal: true

module Blacklight::Oembed
  # Override blacklight-oembed gem controller. We're only interested in
  # get_embed_content, but keep the changes compatible incase we can use
  # Blacklight later
  class EmbedController < ActionController::Base
    def show
      render json: { html: get_embed_content(params[:url], additional_params) }
    end

    private

    def get_embed_content(url, add_params)
      # Retrieve embeddable content from cache, or store if not found
      Rails.cache.fetch("embed/#{url}", expires_in: 12.hours) do
        OEmbed::Providers.get(url, **add_params).html.html_safe
      end
    rescue OEmbed::Error => e
      # Create OembedError for oEmbed Errors dashboard
      FileSet.search_with_conditions(oembed_url_sim: url).each do |file_set|
        OembedError.find_or_create_by(document_id: file_set.id) do |error|
          error.document_id = file_set.id
        end.add_error(e)
      end

      "<dt>oEmbed encounted an error</dt><dd>#{e.message}</dd>".html_safe
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
