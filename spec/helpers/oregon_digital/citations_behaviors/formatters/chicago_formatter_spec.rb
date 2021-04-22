# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::ChicagoFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work)      { build(:work, title: ['<ScrIPt>prompt("Confirm Password")</sCRIpt>']) }

  before do
    allow(presenter).to receive(:author_label).and_return(['last name, first name'])
  end

  it 'sanitizes input' do
    expect(formatter.format(presenter)).not_to include 'prompt'
  end
end
