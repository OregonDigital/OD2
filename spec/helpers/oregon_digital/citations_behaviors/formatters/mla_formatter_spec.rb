# frozen_string_literal: true

RSpec.describe OregonDigital::CitationsBehaviors::Formatters::MlaFormatter do
  subject(:formatter) { described_class.new(:no_context) }

  let(:presenter) { Hyrax::GenericPresenter.new(SolrDocument.new(work.to_solr), :no_ability) }
  let(:work) { build(:work, title: ['My Title']) }

  before do
    allow(presenter).to receive(:author_label).and_return(['last name, first name'])
  end

  it 'displays the work title' do
    expect(formatter.format(presenter)).to include 'My Title'
  end

  it 'displays the creators name' do
    expect(formatter.format(presenter)).to include 'last name, first name'
  end

  it 'displays the creators name in the proper order' do
    allow(presenter).to receive(:creator_label).and_return(['first last'])
    expect(formatter.format(presenter)).to include 'last, first'
  end

  it 'displays the publisher' do
    expect(formatter.format(presenter)).to include 'Oregon Digital'
  end

  it 'displays the publish date' do
    allow(presenter).to receive(:date_created).and_return(['2000'])
    expect(formatter.format(presenter)).to include '2000'
  end

  it 'defaults to now if no publish date exists' do
    expect(formatter.format(presenter)).to include Time.now.strftime('%d %b %Y')
  end
end
