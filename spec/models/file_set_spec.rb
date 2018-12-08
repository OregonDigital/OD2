# frozen_string_literal: true

RSpec.describe FileSet do
  subject { create(:file_set) }

  let(:model) { subject }
  let(:encoded_id) { subject.id.scan(/.{1,2}/).join('%2f') }
  let(:iiif_url) { "#{ENV.fetch('IIIF_SERVER_BASE_URL', 'http://bogus')}/#{encoded_id}" }

  it 'creates a valid jpg iiif url' do
    expect(model.iiif_url('http://bogus')).to eq("#{iiif_url}-jpg.jpg")
  end

  context 'with a mocked jp2' do
    it 'creates a valid jp2 iif url' do
      allow(model).to receive(:derivative_path_for_reference).and_return(File.join(Rails.root, 'spec', 'fixtures', 'test.jpg'))
      expect(model.iiif_url('http://bogus')).to eq("#{iiif_url}-jp2.jp2")
    end
  end
end
