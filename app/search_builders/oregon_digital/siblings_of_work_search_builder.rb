# frozen_string_literal:true

module OregonDigital
  # Finds parent works
  class SiblingsOfWorkSearchBuilder < Hyrax::SearchBuilder
    self.default_processor_chain += [:sibling_works]

    attr_reader :work

    def initialize(*options, work:)
      @work = work
      @parents = work.parents
      super(options.first)
    end

    def sibling_works(solr_params)
      sibling_ids = @parents.map(&:member_ids).flatten
      sibling_ids << '""' if sibling_ids.empty?
      solr_params[:fq] ||= []
      solr_params[:fq] << "id:(#{sibling_ids.join(' OR ')})"
      solr_params[:fq] << "-id:(#{@work.id})"
      solr_params[:fq] << '-has_model_ssim:*FileSet'
    end
  end
end
