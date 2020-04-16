# frozen_string_literal: true

# OVERRIDE to fetch value so rdf_label actually works
class FetchedControlledVocabularyInput < ControlledVocabularyInput
  private

  def build_options_for_existing_row(_attribute_name, _index, value, options)
    value.fetch(RDF::Util::File::HttpAdapter.default_accept_header.sub(%r{, \*\/\*;q=0\.1\Z}, ''))
    options[:value] = value.rdf_label.first || "Unable to fetch label for #{value.rdf_subject}"
    options[:readonly] = true
  end
end
