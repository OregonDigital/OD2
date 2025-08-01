# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create triplestore health graph'
  task :create_triplestore_health do
    client = TriplestoreAdapter::Client.new(ENV['TRIPLESTORE_ADAPTER_TYPE'], ENV['TRIPLESTORE_ADAPTER_URL'])
    ts = TriplestoreAdapter::Triplestore.new(client)
    g = RDF::Graph.new
    g << RDF::Statement.new(
      RDF::URI.new('http://example.org/vocab/tshealth'), RDF::Vocab::SKOS.prefLabel, RDF::Literal.new('healthy')
    )
    ts.store(g)
  end
end
