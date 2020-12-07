# frozen_string_literal:true

RSpec.describe OregonDigital::OembedService, clean_repo: true do
  let!(:file_set_with_oembed) do
    build(:file_set, oembed_url: 'https://www.youtube.com/watch?v=8ZtInClXe1Q').tap do |file_set|
      file_set.save(validate: false)
    end
  end
  let!(:file_set_without_oembed) do
    build(:file_set).tap do |file_set|
      file_set.save(validate: false)
    end
  end
  let(:returned_pids) { described_class.assets_with_oembed.map(&:id) }

  it { expect(returned_pids).not_to include file_set_without_oembed.id }
  it { expect(returned_pids).to include file_set_with_oembed.id }
end
