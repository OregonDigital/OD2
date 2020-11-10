# frozen_string_literal:true

module OregonDigital
  # Converts a work to a work type presenter
  class WorkToPresenterConverter
    # rubocop:disable Metrics/MethodLength
    def self.convert_to_presenter(work, current_ability)
      work_type = work.class
      solr_doc = SolrDocument.find(work.id)
      @work_presenter = ''
      case work_type.to_s
      when 'Generic'
        @work_presenter = Hyrax::GenericPresenter.new(solr_doc, current_ability)
      when 'Image'
        @work_presenter = Hyrax::ImagePresenter.new(solr_doc, current_ability)
      when 'Video'
        @work_presenter = Hyrax::VideoPresenter.new(solr_doc, current_ability)
      when 'Document'
        @work_presenter = Hyrax::DocumentPresenter.new(solr_doc, current_ability)
      when 'Audio'
        @work_presenter = Hyrax::AudioPresenter.new(solr_doc, current_ability)
      end
      return @work_presenter
    end
    # rubocop:enable Metrics/MethodLength
  end
end
