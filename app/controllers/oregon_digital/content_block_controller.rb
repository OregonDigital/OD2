# frozen_string_literal: true

module OregonDigital
  # Controller for updating content blocks for tombstones
  class ContentBlocksController < ApplicationController
    def update
      @content_block = ContentBlock.find_by(name: params[:name])
      @content_block.update(value: CGI.unescapeHTML(params[:content_block][:content]))
      @work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: @content_block.name.split('-').last)
      redirect_to polymorphic_path(@work)
    end
  end
end
