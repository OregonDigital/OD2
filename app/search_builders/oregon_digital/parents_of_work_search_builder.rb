# frozen_string_literal:true

module OregonDigital
  # Finds parent works
  class ParentsOfWorkSearchBuilder < Blacklight::SearchBuilder
    self.default_processor_chain += [:parent_works]

    attr_reader :work

    def initialize(work:)
      @work = work
      super
    end

    def parent_works(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << "member_ids_ssim:(#{work.id})"
    end
  end
end
