# frozen_string_literal:true

RSpec.describe OregonDigital::Derivatives::Image::JP2Runner do
  let(:fixture) { "#{Rails.root}/spec/fixtures/test.jpg" }
  let(:source) do
    f = Tempfile.new(['od2-test', '.bmp'])
    p = f.path
    f.close
    f.unlink
    p
  end

  describe '#create' do
    before do
      # GraphicsMagick can't read the JP2.  ImageMagick can't deal with huge
      # images, which is why we use GM by default, but in the case of this
      # test, we don't have a huge image.
      #
      # Why a configure block?  #with_cli is not working.  Not sure why.
      MiniMagick.configure do |config|
        config.cli = :imagemagick
      end

      # Now even more fun: convert our test.jpg into a BMP because
      # opj_decompress doesn't do jpg directly, and we don't really want to add
      # a 500k file just for this one test
      MiniMagick::Image.open(fixture).format('bmp').write(source)
    end

    subject do
      outfile = '/tmp/foo.jp2'
      described_class.create(source,
                             outputs: [
                               { label: :jp2,
                                 mime_type: 'image/jpeg',
                                 tile_size: 1024,
                                 compression: 1,
                                 url: URI("file://#{outfile}"),
                                 layer: 0 }
                             ])
      MiniMagick::Image.open(outfile)
    end

    it { is_expected.to have_attributes(type: 'JP2') }
    it { is_expected.to have_attributes(width: 520) }
    it { is_expected.to have_attributes(height: 343) }
  end
end
