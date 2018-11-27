# frozen_string_literal: true

RSpec.describe FileSet do
  subject { create(:file_set) }
  let(:encoded_id) { subject.id.scan(/.{1,2}/).join('%2f') }
  let(:iif_url) { "#{ENV.fetch('IIIF_SERVER_BASE_URL', 'http://bogus')}/#{encoded_id}" }

  it 'creates a valid jpg iiif url' do
    expect(subject.iiif_url('http://bogus')).to eq("#{iif_url}-jpg.jpg")
  end

  context 'for a mocked jp2' do
    it 'creates a valid jp2 iif url' do
      allow(subject).to receive(:derivative_path_for_reference).and_return(File.join(Rails.root, 'spec', 'fixtures', 'test.jpg'))
      expect(subject.iiif_url('http://bogus')).to eq("#{iif_url}-jp2.jp2")
    end
  end
end
