# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::ApaFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work)      { build(:work, title: ['Title']) }

  before do
    allow(presenter).to receive(:author_label).and_return(['last name, first name'])
  end

  it 'formats citations without creators' do
    expect(formatter.format(presenter)).to eq('<span class=\"citation-author\">last name, f.</span> (21 Apr 2021). <i class=\"citation-title\">Title.</i> Oregon Digital. ')
  end
end
