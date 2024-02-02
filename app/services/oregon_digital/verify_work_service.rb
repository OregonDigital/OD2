# frozen_string_literal:true

module OregonDigital::Services
  # Called by the VerifyWorkJob
  # Runs the verification suite and adds any returned errors to the work
  # required args: pid
  # optional args: verify_services, a list of verification classes
  class VerifyWorkService
    def initialize(args)
      @args = args
      @services = services
    end

    def run
      @services.each do |service|
        verifier = service.new(@work)
        verifier.verify.each do |k,v|
          if v.blank?
            @work.errors.delete(k)
          else
            v.each do |message|
              @work.errors.add(k, message)
            end
          end
        end
      end
    end

    def solr_doc
      @solr_doc = SolrDocument.find(@args[:pid])
    end

    def resource_type
      @solr_doc['has_model_ssim'].first
    end

    def work
      @work ||= resource_type.constantize.find(@args[:pid])
    end

    # allow a different list of services to be used on the fly
    def services
      return OD2::Application.config.verify_services if @args[:verify_services].blank?

      services = []
      @args[:verify_services].each do |s|
        services << s.constantize
      end
      services
    end
  end
end

