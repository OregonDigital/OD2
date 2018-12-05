# frozen_string_literal:true

RSpec.describe OregonDigital::OembedService do
  let!(:work_with_oembed) do
    build(:work, oembed_url: 'https://www.youtube.com/watch?v=8ZtInClXe1Q').tap do |work|
      work.save(validate: false)
    end
  end
  let!(:work_without_oembed) do
    build(:work).tap do |work|
      work.save(validate: false)
    end
  end
  let(:returned_pids) { described_class.assets_with_oembed.map(&:id) }

  it { expect(returned_pids).not_to include work_without_oembed.id }
  it { expect(returned_pids).to include work_with_oembed.id }
end
