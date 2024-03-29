# frozen_string_literal:true

module OregonDigital
  # Finds parent works
  class ParentsSearchBuilder < Blacklight::SearchBuilder
    self.default_processor_chain += [:parent_works]

    attr_reader :work

    def initialize(id:)
      @id = id
      super
    end

    def parent_works(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << "member_ids_ssim:(#{@id})"
    end
  end
end
