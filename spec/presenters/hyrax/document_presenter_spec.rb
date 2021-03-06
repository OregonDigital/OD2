# frozen_string_literal:true

RSpec.describe Hyrax::DocumentPresenter do
  let(:presenter) { described_class.new(solr_document, ability) }
  let(:model) { build(:document) }
  let(:ability) { instance_double('Ability') }
  let(:solr_document) { SolrDocument.new(model.attributes) }
  let(:props) { Document.document_properties.map(&:to_sym) }

  it 'delegates the method to solr document' do
    props.each do |prop|
      expect(presenter).to delegate_method(prop).to(:solr_document)
    end
  end
end
