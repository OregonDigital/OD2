# frozen_string_literal:true

module OregonDigital
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
        verifier = service.new(service_args)
        verifier.verify.each do |k, v|
          work.remove_errors(k)
          add_errors(k, v) unless v.blank?
        end
      end
    end

    def add_errors(key, messages)
      messages.each do |message|
        work.add_error(key, message)
      end
    end

    def service_args
      @service_args ||=
        {
          solr_doc: solr_doc,
          work: work
        }
    end

    def solr_doc
      @solr_doc = SolrDocument.find(@args[:pid])
    end

    def resource_type
      solr_doc['has_model_ssim'].first
    end

    def work
      @work ||= Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: @args[:pid])
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
