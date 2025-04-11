# frozen_string_literal:true

module OregonDigital
  # Finds subset of ordered child works, i.e. for a given page
  class OrderedChildrenOfWorkSearchBuilder < Hyrax::SearchBuilder
    self.default_processor_chain += [:ordered_child_works]

    attr_reader :work

    def initialize(*options, work:)
      @work = work
      super(options.first)
      @child_page = options.first.params['child_page']
      # page must be set to 1, otherwise search builder assumes
      # that all docs have already been returned on the previous page
      options.first.params['page'] = '1'
      @count = blacklight_config.per_page.first
    end

    def ordered_child_works(solr_params)
      ids = @work.ordered_member_ids || ['""']
      ids = ids.slice(find_start(@child_page), @count)
      solr_params[:fq] ||= []
      solr_params[:fq] << "id:(#{ids.join(' OR ')})"
      solr_params[:fq] << '-has_model_ssim:*FileSet'
    end

    def find_start(page)
      return 0 if page.nil?

      return (page.to_i - 1) * @count
    end
  end
end
