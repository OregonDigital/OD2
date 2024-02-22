# frozen_string_literal: true

# OVERRIDE to fetch value so rdf_label actually works
class LabelAndUriControlledVocabularyInput < ControlledVocabularyInput
  private

  def build_options_for_existing_row(attribute_name, index, value, options)
    solr_document_label_uri = SolrDocument.find(object.model.id).send(:label_uri_helpers, attribute_name)[index]
    options[:value] = "#{solr_document_label_uri['label']} (#{solr_document_label_uri['uri']})" || "Unable to fetch label for #{solr_document_label_uri['uri']}"
    options[:readonly] = true
  end
end
