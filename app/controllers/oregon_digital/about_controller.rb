# frozen_string_literal:true

module OregonDigital
  # This controller sets up the static about pages.
  class AboutController < ApplicationController
    layout 'oregon_digital/about'

    def about
      add_breadcrumb t(:'hyrax.controls.home'), root_path
    end

    def osu
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def uo
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def copyright
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def harmful
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def privacy
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def takedown
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def terms
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def mission
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def use
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end

    def recommend
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.controls.about'), about_path
    end
  end
end
