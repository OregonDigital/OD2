# frozen_string_literal: true

describe OregonDigital::FileSetAltTextsExtractorService do
  # SETUP: Create a test variable
  let(:file_path) { '/path/image.tif' }
  let(:alt_text_value) { 'test value' }

  # TEST: To see the alt text can be extracted from the file
  describe '#extract' do
    context 'when file has alt text in the field' do
      before do
        # MOCK: Fake the shell command so we dont need a real file
        allow_any_instance_of(Object).to receive(:`).and_return("#{alt_text_value}\n")
      end

      it 'returns the alt text value' do
        result = described_class.extract(file_path)
        expect(result).to eq('test value')
      end
    end
  end
end
