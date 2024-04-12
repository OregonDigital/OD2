# frozen_string_literal:true

# WIP
RSpec.describe OregonDigital::Derivatives::Document::TesseractRunner do
  let(:file_set) { create(:file_set) }
  let(:source) { "#{Rails.root}/spec/fixtures/test.jpg" }
  let(:hocr_content ) { File.read(Rails.root.join('spec', 'fixtures', 'test.hocr')) }

  describe '#create' do
    subject do
      outfile = '/tmp/foo'
      described_class.create(source,
                             outputs: [
                               { url: file_set.uri,
                                 container: 'hocr' }
                             ])
      file_set.reload
      byebug
      file_set.hocr[0].content
    end

    it { is_expected.to_not be_blank }
    it { is_expected.to eq hocr_content }
  end
end
