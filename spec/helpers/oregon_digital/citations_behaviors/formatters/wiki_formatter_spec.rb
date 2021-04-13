# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::WikiFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work) { build(:work, title: ['My Title'], author: ['My Author'], publisher: ['My Publisher']) }
  let(:view_context) { double('View Context') }
  let(:controller) { double('Controller') }
  let(:original_url) { 'http://test.oregondigital.org/blah/blah/12345678?q=blah' }

  before do
    allow(presenter).to receive(:creator_label).and_return(['last name, first name'])
    allow(formatter).to receive(:view_context).and_return(view_context)
    allow(view_context).to receive(:controller).and_return(controller)
    allow(controller).to receive(:original_url).and_return(original_url)
  end

  it 'displays the citation' do
    expect(formatter.format(presenter)).to eq "<ref name=Oregon Digital>{{cite web | url= http://test.oregondigital.org/blah/blah/12345678?q=blah | title= My Title |author= My Author |accessdate= #{Date.today} |publisher= My Publisher}}</ref>"
  end
end
