# frozen_string_literal:true

# SearchBuilder for full-text searches with highlighting and snippets
class IiifSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:ocr_search_params]

  # set params for ocr field searching
  def ocr_search_params(solr_parameters = {})
    solr_parameters[:q] = "#{solr_parameters[:q]}*"
    solr_parameters[:qf] = blacklight_config.iiif_search[:full_text_field]
    # set the highlighting parameters
    ocr_search_highlight_params(solr_parameters)
    # catalog controller puts params here when you call search_results
    solr_parameters[:fq] += blacklight_params[:fq]
  end

  def ocr_search_highlight_params(solr_parameters = {})
    solr_parameters[:hl] = true
    solr_parameters[:'hl.fl'] = blacklight_config.iiif_search[:full_text_field]
    solr_parameters[:'hl.snippets'] = 10_000
    solr_parameters[:'hl.fragsize'] = solr_parameters[:q].split(' ').map(&:length).max
    solr_parameters[:'hl.maxAnalyzedChars'] = -1
  end
end
