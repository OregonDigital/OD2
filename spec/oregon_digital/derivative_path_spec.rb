# frozen_string_literal:true

RSpec.describe OregonDigital::DerivativePath do
  let(:bucket) { 'derivatives' }
  let(:id) { 'asdfghjkl' }
  let(:dp) { described_class.new(bucket: bucket, id: id) }

  describe '#url' do
    it 'works' do
      expect(dp.url(label: 'foo').to_s).to eq('s3://derivatives/as/df/gh/jk/l-foo.foo')
    end

    it 'splits the id to generate the path' do
      expect(dp.url(label: 'foo').path).to eq('/as/df/gh/jk/l-foo.foo')
    end

    it 'returns a valid URI' do
      expect(dp.url(label: 'foo')).to be_kind_of(URI)
    end

    it 'puts the bucket into the URL as the hostname' do
      expect(dp.url(label: 'FOO').host).to eq(bucket)
    end

    it 'converts thumbnails to jpg' do
      expect(File.extname(dp.url(label: 'thumbnail').path)).to eq('.jpg')
    end

    it 'converts zoombales to jp2' do
      expect(File.extname(dp.url(label: 'zoomable').path)).to eq('.jp2')
    end

    it 'uses the label to determine extension' do
      expect(File.extname(dp.url(label: 'blah').path)).to eq('.blah')
    end
  end
end
