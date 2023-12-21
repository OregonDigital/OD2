# frozen_string_literal: true

# OVERRIDE to fetch value so rdf_label actually works
class LabelAndUriControlledVocabularyInput < ControlledVocabularyInput
  private

  def build_options_for_existing_row(attribute_name, index, value, options)
    solr_document_label = SolrDocument.find(object.model.id).send("#{attribute_name}_label")[index]
    value_uri = value.rdf_subject
    options[:value] = "#{solr_document_label} (#{value_uri})" || "Unable to fetch label for #{value.rdf_subject}"
    options[:readonly] = true
  end
end
