require 'hyrax/specs/shared_specs'

RSpec.describe OregonDigital::FileSetDerivativesService do
  let(:mime_type) { 'image/tiff' }
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type).and_return(mime_type)
    end
  end

  subject { described_class.new(valid_file_set) }

  it_behaves_like 'a Hyrax::DerivativeService'

  it 'processes a tiff into a jp2' do
    allow(subject).to receive(:create_jp2_image_derivatives).and_return true
    expect(subject).to receive(:create_jp2_image_derivatives)
    subject.create_derivatives('bogus/file_path/image.tiff')
  end

  context 'with a jp2' do
    let(:mime_type) { 'image/jp2' }
    it 'processes the image' do
      allow(subject).to receive(:create_jp2_image_derivatives).and_return true
      expect(subject).to receive(:create_jp2_image_derivatives)
      subject.create_derivatives('bogus/file_path/image.jp2')
    end
  end

  context 'with images other than tiff or jp2' do
    let(:mime_type) { 'image/gif' }
    it 'processes the image' do
      allow(subject).to receive(:create_image_derivatives).and_return true
      expect(subject).to receive(:create_image_derivatives)
      subject.create_derivatives('bogus/file_path/image.gif')
    end
  end
end
