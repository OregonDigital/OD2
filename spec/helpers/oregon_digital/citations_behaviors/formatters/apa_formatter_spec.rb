# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::ApaFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work)      { build(:work, title: ['Title'], creator: []) }

  it 'formats citations without creators' do
    expect(formatter.format(presenter)).to eq('<i class=\"citation-title\">Title.</i> ')
  end
end
