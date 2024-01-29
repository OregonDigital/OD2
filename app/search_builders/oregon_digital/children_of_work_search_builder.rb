# frozen_string_literal:true

module OregonDigital
  # Finds parent works
  class ChildrenOfWorkSearchBuilder < Hyrax::SearchBuilder
    self.default_processor_chain += [:child_works]

    attr_reader :work

    def initialize(*options, work:)
      @work = work
      super(options.first)
    end

    def child_works(solr_params)
      ids = work['member_ids_ssim'] || []
      ids << '""' if ids.empty?
      solr_params[:fq] ||= []
      solr_params[:fq] << "id:(#{ids.join(' OR ')})"
      solr_params[:fq] << '-has_model_ssim:*FileSet'
    end
  end
end
