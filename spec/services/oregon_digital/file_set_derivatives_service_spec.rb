# frozen_string_literal:true

require 'hyrax/specs/shared_specs'

RSpec.describe OregonDigital::FileSetDerivativesService do
  subject { service }

  let(:service) { described_class.new(valid_file_set) }
  let(:mime_type) { 'image/tiff' }
  let(:uri) { 'http://example.org/1/2/3/foo' }
  let(:valid_file_set) do
    FileSet.new.tap do |f|
      allow(f).to receive(:mime_type).and_return(mime_type)
      allow(f).to receive(:uri).and_return(uri)
    end
  end

  it_behaves_like 'a Hyrax::DerivativeService'

  describe '#create_derivatives' do
    [
      [FileSet.pdf_mime_types,             :create_pdf_derivatives],
      [FileSet.office_document_mime_types, :create_office_document_derivatives],
      [FileSet.audio_mime_types,           :create_audio_derivatives],
      [FileSet.video_mime_types,           :create_video_derivatives],
      [FileSet.image_mime_types,           :create_image_derivatives]
    ].each do |mimes, callee|
      mimes.each do |mime|
        context "with a #{mime} source" do
          let(:mime_type) { mime }
          let(:callee) { callee }

          it "runs #{callee}" do
            allow(service).to receive(callee).and_return true
            expect(service).to receive(callee).once
            service.create_derivatives('bogus/file/path')
          end
        end
      end
    end
  end

  describe '#create_image_derivatives' do
    let(:bogus_jpg) { '/bogus/path/to/file.jpg' }
    let(:tmp_bmp) { '/tmp/path/to/file.bmp' }

    before do
      allow(OregonDigital::Derivatives::Image::Utils).to receive(:tmp_file).with('bmp').and_yield(tmp_bmp)
      allow(service).to receive(:preprocess_image)
      allow(service).to receive(:create_thumbnail)
      allow(service).to receive(:create_zoomable)
    end

    it 'preprocesses the image' do
      expect(service).to receive(:preprocess_image).with(bogus_jpg, tmp_bmp)
      service.create_image_derivatives(bogus_jpg)
    end

    it 'creates a thumbnail from the bitmap' do
      expect(service).to receive(:create_thumbnail).with(tmp_bmp)
      service.create_image_derivatives(bogus_jpg)
    end

    it 'creates a zoomable image from the bitmap' do
      expect(service).to receive(:create_zoomable).with(tmp_bmp)
      service.create_image_derivatives(bogus_jpg)
    end
  end

  describe '#preprocess_image' do
    let(:source) { '/bogus/path/to/file.xyzzy' }
    let(:tmp_bmp) { '/tmp/path/to/file.bmp' }

    context 'with a JP2' do
      let(:mime_type) { 'image/jp2' }

      it 'runs the jp2 preprocessor to generate the bmp' do
        expect(service).to receive(:jp2_to_bmp).with(source, tmp_bmp)
        service.preprocess_image(source, tmp_bmp)
      end
    end

    context 'with a BMP' do
      let(:mime_type) { 'image/bmp' }

      it 'runs the bmp preprocessor to generate the bmp' do
        expect(service).to receive(:bmp_to_bmp).with(source, tmp_bmp)
        service.preprocess_image(source, tmp_bmp)
      end
    end

    (FileSet.image_mime_types - ['image/jp2', 'image/bmp']).each do |mime|
      context "with a #{mime}" do
        let(:mime_type) { mime }
        let(:minimagick) { double }

        before do
          allow(MiniMagick::Image).to receive(:open).with(source).and_return(minimagick)
          allow(minimagick).to receive(:format).with('bmp').and_return(minimagick)
          allow(minimagick).to receive(:write).with(tmp_bmp)
        end

        it 'runs minimagick to generate a bmp' do
          expect(minimagick).to receive(:write).with(tmp_bmp)
          service.preprocess_image(source, tmp_bmp)
        end
      end
    end
  end

  describe '#jp2_to_bmp' do
    let(:processor) { double }

    before do
      allow(service).to receive(:jp2_processor).and_return(processor)
      allow(processor).to receive(:opj_decompress).and_return('tool')
    end

    it "runs the processor's execute method" do
      expect(processor).to receive(:execute).with('tool -i foo.jp2 -o bar.bmp')
      service.jp2_to_bmp('foo.jp2', 'bar.bmp')
    end

    it 'escapes shell-dangerous source and destinations' do
      expect(processor).to receive(:execute).with('tool -i foo\"bar -o baz\ \|\|\ exit\ 1')
      service.jp2_to_bmp('foo"bar', 'baz || exit 1')
    end
  end

  describe '#bmp_to_bmp' do
    before do
      allow(File).to receive(:unlink).with('tmp.bmp')
      allow(FileUtils).to receive(:ln_s).with('orig.bmp', 'tmp.bmp')
    end

    it 'removes the temp file' do
      expect(File).to receive(:unlink).with('tmp.bmp')
      service.bmp_to_bmp('orig.bmp', 'tmp.bmp')
    end

    it 'symlinks the source bmp' do
      expect(FileUtils).to receive(:ln_s).with('orig.bmp', 'tmp.bmp')
      service.bmp_to_bmp('orig.bmp', 'tmp.bmp')
    end
  end
end
