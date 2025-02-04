# frozen_string_literal:true

module OregonDigital
  # Finds parent works
  class ParentsSearchBuilder < Hyrax::SearchBuilder
    self.default_processor_chain += [:parent_works]

    attr_reader :work

    def initialize(*options, id:)
      @id = id
      super(options.first)
    end

    def parent_works(solr_params)
      solr_params[:fq] ||= []
      solr_params[:fq] << "member_ids_ssim:(#{@id})"
    end
  end
end
