# frozen_string_literal:true

RSpec.describe OregonDigital::Derivatives::Document::PDFToTextRunner do
  let(:file_set) { create(:file_set) }
  let(:source) { "#{Rails.root}/spec/fixtures/upload.pdf" }
  let(:extracted_text) { double }
  let(:extracted_text_content) { File.read(Rails.root.join('spec', 'fixtures', 'upload.xml')) }
  let(:bbox_content) { File.read(Rails.root.join('spec', 'fixtures', 'upload.txt')) }

  describe '#create' do
    before do
      allow(extracted_text).to receive(:content).and_return(extracted_text_content)
      allow(file_set).to receive(:extracted_text).and_return(extracted_text)
    end

    context 'when creating a bbox' do
      subject do
        described_class.create(source,
                               outputs: [
                                 { url: file_set.uri,
                                   container: 'bbox' }
                               ])
        file_set.reload
        file_set.bbox.content
      end

      it { is_expected.not_to be_blank }
      it { is_expected.to eq bbox_content }
    end
  end
end
