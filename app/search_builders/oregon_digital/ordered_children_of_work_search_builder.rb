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
      options.first.params['page'] = '1'
      @count = blacklight_config.per_page.first
    end

    def ordered_child_works(solr_params)
      ids = query_for_ordered_ids || ['""']
      ids = ids.slice(find_start(@child_page), @count)
      solr_params[:fq] ||= []
      solr_params[:fq] << "id:(#{ids.join(' OR ')})"
      solr_params[:fq] << '-has_model_ssim:*FileSet'
    end

    def find_start(page)
      return 0 if page.nil?

      return (page.to_i - 1) * @count
    end

    # copied from Hyrax::SolrDocument::OrderedMembers
    def query_for_ordered_ids(limit: 10_000,
                              proxy_field: 'proxy_in_ssi',
                              target_field: 'ordered_targets_ssim')
      Hyrax::SolrService
        .query("#{proxy_field}:#{@work.id}", rows: limit, fl: target_field)
        .flat_map { |x| x.fetch(target_field, nil) }
        .compact
    end
  end
end
