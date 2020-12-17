# frozen_string_literal: true

RSpec.describe OregonDigital::HocrDerivativeService do
  let(:derivative_service) do
    OregonDigital::HocrDerivativeService::Factory.new(file_set: file_set, filename: file_path, processor_factory: processor_factory)
  end
  let(:processor_factory) { OregonDigital::HocrDerivativeService::TesseractProcessor }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'test.jpg') }
  let(:file) { File.read(file_path) }
  let(:file_set) { build(:file_set, file: file) }

  describe '#create_derivatives' do
    context 'with a pdf source' do
      let(:hocr_content) { File.read(Rails.root.join('spec', 'fixtures', 'test.hocr')) }
      let(:ocr_content) { File.read(Rails.root.join('spec', 'fixtures', 'test.ocr')) }
      let(:service) { derivative_service.new }

      before do
        processor = processor_factory.new(ocr_language: 'eng', file_path: file_path)
        allow(processor_factory).to receive(:new).and_return(processor)

        service.create_derivatives
      end

      it 'sets hocr_content on the fileset' do
        expect(file_set.hocr_content).not_to be_blank
      end

      it 'sets ocr_content on the fileset' do
        expect(file_set.ocr_content).not_to be_blank
      end

      it 'returns the correct hOCR content' do
        expect(file_set.hocr_content.first).to eq hocr_content
      end

      it 'returns the correct OCR content' do
        expect(file_set.ocr_content.first).to eq ocr_content.strip
      end
    end
  end
end
