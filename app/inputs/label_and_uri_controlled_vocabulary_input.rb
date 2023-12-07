# frozen_string_literal: true

# OVERRIDE to fetch value so rdf_label actually works
class LabelAndUriControlledVocabularyInput < ControlledVocabularyInput
  private

  def build_options_for_existing_row(attribute_name, index, value, options)
    if attribute_name.to_s == 'subject'
      subject_terms = find_subject_term(attribute_name)
      solr_document_label = subject_terms[index]
      value_uri = value.rdf_subject
      options[:value] = "#{solr_document_label} (#{value_uri})" || "Unable to fetch label for #{value.rdf_subject}"
      options[:readonly] = true
    else
      solr_document_label = SolrDocument.find(object.model.id).send("#{attribute_name}_label")[index]
      value_uri = value.rdf_subject
      options[:value] = "#{solr_document_label} (#{value_uri})" || "Unable to fetch label for #{value.rdf_subject}"
      options[:readonly] = true
    end
  end

  def find_subject_term(attribute_name)
    # FIND: Find all the subject uri
    subject_arr = SolrDocument.find(object.model.id).send("#{attribute_name}")

    # CREATE: Create empty arr
    sub_term_arr = []

    # LOOP: Loop through and add in updated term to check depreciated links
    subject_arr.each_with_index do |val, ind|
      # FETCH: Begin to fetch uri and label
      prop = Generic.properties[attribute_name.to_s].class_name.new(val)
      begin
        prop.fetch
        solrized = prop.solrize
      rescue TriplestoreAdapter::TriplestoreException => e
        Rails.logger.warn "Failed to fetch #{val} from cache AND source. #{e.message}"
      end
      sub_term_arr << solrized_term(solrized).first if !solrized_term(solrized).blank?  || ["Label Does Not Exist"]
    end
    sub_term_arr
  end

  # METHOD: To solrized term
  def solrized_term(solrized)
    solrized&.[](1)&.[](:label)&.split('$')
  end
end
