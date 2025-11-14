# frozen_string_literal:true

module Hyrax
  # Generated controller for Audio
  class AudiosController < ApplicationController
    load_and_authorize_resource except: [:manifest]

    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include OregonDigital::PresentsDataSources
    include OregonDigital::DownloadControllerBehavior
    include OregonDigital::WorksControllerBehavior
    include OregonDigital::WorkRelationPaginationBehavior

    # Redirect for Bot Detection
    before_action do |controller|
      BotDetectionController.bot_detection_enforce_filter(controller) unless valid_bot? # oregon-explorer.apps.geocortex.com tools.oregonexplorer.info oregondigital.org staging.oregondigital.org test.lib.oregonstate.edu:3000
    end

    # 'ir.library.oregonstate.edu,ir-staging.library.oregonstate.edu,test.lib.oregonstate.edu:3000'
    def valid_bot?
      ENV.fetch('URI_TURNSTILE_BYPASS', '').split(',').include?(request.domain) || allow_listed_ip_addr?
    end

    def allow_listed_ip_addr?
      ips = ENV.fetch('IP_TURNSTILE_BYPASS', '') # '127.0.0.1-127.255.255.255,66.249.64.0-66.249.79.255'
    ranges = ips.split(',')
    ranges.each do |range|
      range = range.split('-')
      range = (IPAddr.new(range[0]).to_i..IPAddr.new(range[1]).to_i)
      return true if range.include?(IPAddr.new(request.remote_ip).to_i)
    end
    false
    end

    self.curation_concern_type = ::Audio

    # Remove list view from child/sibling renders
    configure_blacklight do |config|
      config.view.list.if = false
    end

    # Override the way Hyrax's works present iiif manifests
    include OregonDigital::IIIFManifestControllerBehavior

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::AudioPresenter
  end
end
