# frozen_string_literal:true

RSpec.describe OregonDigital::OembedPresenter do
  let(:document) { SolrDocument.new(attributes) }
  let(:presenter) { described_class.new(document) }
  let(:attributes) do
    {
      'title_tesim' => ['Hey guys!'],
      'oembed_url_tesim' => ['https://www.youtube.com/watch?v=8ZtInClXe1Q'],
      'human_readable_type_tesim' => ['File']
    }
  end
  let(:props) { %i[oembed_url human_readable_type to_s] }

  describe '#to_s' do
    subject { presenter.to_s }

    it { is_expected.to eq 'Hey guys!' }
  end

  describe '#oembed_url' do
    subject { presenter.oembed_url }

    it { is_expected.to eq ['https://www.youtube.com/watch?v=8ZtInClXe1Q'] }
  end

  describe '#human_readable_type' do
    subject { presenter.human_readable_type }

    it { is_expected.to eq 'File' }
  end

  it 'delegates the method to solr document' do
    props.each do |prop|
      expect(presenter).to delegate_method(prop).to(:solr_document)
    end
  end
end
