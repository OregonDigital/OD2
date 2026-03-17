# frozen_string_literal: true
module Hyrax
	# Draws a collapsable list widget using the Bootstrap 3 / Collapse.js plugin
	class CollapsableSectionPresenter
    def initialize(view_context:, text:, id:, icon_class:, open:, title: nil)
      @view_context = view_context
      @text = text
      @id = id
      @icon_class = icon_class
      @open = open
      @title = title
    end
      
	  attr_reader :view_context, :text, :id, :icon_class, :open
	  delegate :content_tag, :safe_join, :tag, to: :view_context
      
	  def render(&block)
	    list_tag(&block)
	  end
      
	  private
      
	  def list_tag
	    tag.ul(class: "collapse nav nav-pills nav-stacked dropdown", id: id) do
	      yield
	    end
	  end
      
	  def button_class
	    'collapsed ' unless open
	  end
	end
      end