# frozen_string_literal: true

# OVERRIDE to fetch value so rdf_label actually works
class LabelAndUriControlledVocabularyInput < ControlledVocabularyInput
  private

  def build_options_for_existing_row(attribute_name, index, _value, options)
byebug
    # FETCH: Get the label$uri out from parser => [{label: , uri: }]
    solr_document_label_uri = SolrDocument.find(object.model.id).send(:label_uri_helpers, attribute_name)[index]

    # CHECK: If the label is blank, use a default message instead
    label = !solr_document_label_uri['label'].empty? ? solr_document_label_uri['label'] : 'Unable to fetch label'

    # SET: Set the value to the corresponding area
    options[:value] = "#{label} (#{solr_document_label_uri['uri']})"
    options[:readonly] = true
  end
end
