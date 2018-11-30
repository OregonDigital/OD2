# frozen_string_literal:true

RSpec.describe OregonDigital::Derivatives::Image::GMRunner do
  let(:source) { "#{Rails.root}/spec/fixtures/test.jpg" }

  describe '#create' do
    context 'when creating a png thumbnail' do
      subject do
        outfile = '/tmp/foo.png'
        described_class.create(source,
                               outputs: [
                                 { label: :thumb,
                                   size: '120x120>',
                                   format: 'png',
                                   url: URI("file://#{outfile}"),
                                   layer: 0 }
                               ])
        MiniMagick::Image.open(outfile)
      end

      it { is_expected.to have_attributes(type: 'PNG') }
      it { is_expected.to have_attributes(width: 120) }
      it { is_expected.to have_attributes(height: 79) }
    end
  end
end
