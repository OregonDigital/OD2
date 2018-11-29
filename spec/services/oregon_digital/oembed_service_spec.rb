RSpec.describe OregonDigital::OembedService do
  subject { described_class }

  let!(:work_with_oembed) do
    build(:work, oembed_url: "https://www.youtube.com/watch?v=8ZtInClXe1Q").tap do |work|
      work.save(validate: false)
    end
  end
  let!(:work_without_oembed) do
    build(:work).tap do |work|
      work.save(validate: false)
    end
  end

  describe "#assets_with_oembed" do
    it 'returns an array of assets with oembed urls' do
      returned_pids = subject.assets_with_oembed.map(&:id)
      expect(returned_pids).to include work_with_oembed.id
      expect(returned_pids).not_to include work_without_oembed.id
    end
  end
end
