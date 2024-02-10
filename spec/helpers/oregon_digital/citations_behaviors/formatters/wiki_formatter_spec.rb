# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::WikiFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work) { build(:work, title: ['My Title']) }
  let(:view_context) { double('View Context') }
  let(:context) { double('view_context') }
  let(:controller_request) { double('view_context_controller_request') }
  let(:original_url) { 'http://test.oregondigital.org/blah/blah/12345678?q=blah' }

  before do
    allow(presenter).to receive(:author_label).and_return(['last name, first name'])
    allow(presenter).to receive(:publisher_label).and_return(['My Publisher'])
    allow(formatter).to receive(:view_context).and_return(view_context)
    allow(view_context).to receive(:controller).and_return(context)
    allow(context).to receive(:request).and_return(controller_request)
    allow(controller_request).to receive(:original_url).and_return(original_url)
  end

  it 'displays the citation' do
    expect(formatter.format(presenter)).to eq "{{cite web | url= http://test.oregondigital.org/blah/blah/12345678 | title= My Title |author= last name, first name |accessdate= #{Date.today} |publisher= My Publisher}}"
  end
end
