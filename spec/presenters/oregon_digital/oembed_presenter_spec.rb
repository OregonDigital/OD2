RSpec.describe OregonDigital::OembedPresenter do
  let(:document) { SolrDocument.new(attributes) }
  let(:presenter) { described_class.new(document) }
  let(:attributes) { {} }

  describe "to_s" do
    let(:attributes) { { 'title_tesim' => ['Hey guys!'] } }

    subject { presenter.to_s }

    it { is_expected.to eq 'Hey guys!' }
  end

  describe "oembed_url" do
    let(:attributes) { { 'oembed_url_tesim' => ['https://www.youtube.com/watch?v=8ZtInClXe1Q'] } }

    subject { presenter.oembed_url }

    it { is_expected.to eq ['https://www.youtube.com/watch?v=8ZtInClXe1Q'] }
  end

  describe "human_readable_type" do
    let(:attributes) { { 'human_readable_type_tesim' => ['File'] } }

    subject { presenter.human_readable_type }

    it { is_expected.to eq 'File' }
  end
end
