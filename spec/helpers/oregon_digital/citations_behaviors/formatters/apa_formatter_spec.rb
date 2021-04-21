# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::ApaFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work)      { build(:work, title: ['Title']) }

  it 'formats citations without creators' do
    expect(formatter.format(presenter)).to eq('(21 Apr 2021). <i class=\"citation-title\">Title.</i> Oregon Digital.')
  end
end
