# frozen_string_literal:true

RSpec.describe OregonDigital::S3 do
  let(:s3) { described_class.instance }

  describe '.instance' do
    subject { described_class.instance }

    it { is_expected.to have_attributes(access_key_id: ENV['AWS_S3_APP_KEY']) }
    it { is_expected.to have_attributes(secret_access_key: ENV['AWS_S3_APP_SECRET']) }
    it { is_expected.to have_attributes(region: ENV['AWS_S3_REGION']) }

    # This test is hard-coded to ensure when we're in the test environment, we
    # *never* try to hit the real AWS.  Because, yes, that's bitten me.
    it { is_expected.to have_attributes(endpoint: 'http://minio-test:9000') }
  end

  describe 'full stack test' do
    it 'creates buckets and stores files and is very exciting' do
      bucket_name = "foo-#{rand}"
      s3.create_bucket_if_not_exist(bucket_name)
      url = URI("s3://#{bucket_name}/path/and/key/and/stuff.txt")
      obj = s3.object(url)
      dummytext = "Hello, and welcome to minio's S3 instance"
      obj.put(body: dummytext)

      # We don't cache stuff right now, but just in case that changes, we
      # instantiate a new S3 object for validating the object
      xyzzy = described_class.instance
      expect(xyzzy.object(url).get.body.read).to eq(dummytext)
      expect(xyzzy.keys(bucket_name)).to eq(['path/and/key/and/stuff.txt'])
    end
  end

  describe '#client' do
    subject { s3.client }

    it { is_a? Aws::S3::Client }
  end

  describe '#resource' do
    subject { s3.resource }

    it { is_a? Aws::S3::Resource }
  end

  describe '#create_bucket_if_not_exist' do
    let(:bucket_name) { 'foo' }
    let(:s3_resource) { instance_double(Aws::S3::Resource) }
    let(:bucket) { OpenStruct.new(name: bucket_name, exists?: exists) }

    before do
      allow(s3).to receive(:resource).and_return(s3_resource)
      allow(s3_resource).to receive(:bucket).with(bucket_name).and_return(bucket)
    end

    context 'when the bucket already exists' do
      let(:exists) { true }

      it 'does not create a new bucket' do
        expect(s3).not_to receive(:create_bucket)
        s3.create_bucket_if_not_exist(bucket_name)
      end
    end

    context 'when no bucket exists' do
      let(:exists) { false }

      it 'calls :create_bucket' do
        expect(s3).to receive(:create_bucket).with(bucket_name)
        s3.create_bucket_if_not_exist(bucket_name)
      end
    end
  end
end
