# frozen_string_literal: true

RSpec.describe OregonDigital::ExtractedTextDerivativeService do
  let(:derivative_service) do
    OregonDigital::ExtractedTextDerivativeService::Factory.new(file_set: file_set, filename: file_path, processor_factory: processor_factory)
  end
  let(:processor_factory) { OregonDigital::ExtractedTextDerivativeService::PDFToTextProcessor }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'upload.pdf') }
  let(:file) { File.read(file_path) }
  let(:file_set) { build(:file_set, file: file) }

  describe '#create_derivatives' do
    context 'with a pdf source' do
      let(:extracted_text) { File.read(Rails.root.join('spec', 'fixtures', 'upload.xml')) }
      let(:bbox_content) { File.read(Rails.root.join('spec', 'fixtures', 'upload.txt')) }
      let(:service) { derivative_service.new }

      before do
        processor = processor_factory.new(file_path: file_path)
        allow(processor_factory).to receive(:new).and_return(processor)
        result = OregonDigital::ExtractedTextDerivativeService::PDFToTextProcessor::Result.new(bbox_content: extracted_text)
        allow(processor).to receive(:run!).and_return(result)

        service.create_derivatives
      end

      it 'sets bbox_content on the fileset' do
        expect(file_set.bbox_content).not_to be_blank
      end

      it 'returns the correct bbox_content content' do
        expect(file_set.bbox_content).to eq bbox_content
      end
    end
  end
end
