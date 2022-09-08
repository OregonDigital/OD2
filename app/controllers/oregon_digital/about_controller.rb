# frozen_string_literal:true

module OregonDigital
  # This controller sets up the static about pages.
  class AboutController < ApplicationController
    def about
      add_breadcrumb t(:'hyrax.controls.home'), root_path
    end

    def osu; end

    def uo; end

    def copyright; end

    def harmful; end

    def privacy; end

    def takedown; end

    def terms; end

    def mission; end

    def use; end
  end
end
