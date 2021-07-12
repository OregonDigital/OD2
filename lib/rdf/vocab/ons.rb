# frozen_string_literal:true

# Basic ONS RDF Vocab so Hyrax can recognize the qname
class ONS < RDF::StrictVocabulary('http://opaquenamespace.org/ns/')
  term :primarySet,
       label: 'Primary Set',
       'rdf:type' => 'rdfs:Class'
end
