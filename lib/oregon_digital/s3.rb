module OregonDigital
  # S3 houses all our common AWS S3 logic / setup in a framework-agnostic way
  # so we can include this code in the derivatives services and the main OD app
  class S3
    attr_reader :endpoint, :region, :access_key_id, :secret_access_key

    def initialize(endpoint: nil, region:, access_key_id:, secret_access_key:)
      @endpoint = endpoint
      @region = region
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @bucket_exists = Hash.new
    end

    # Returns a preconfigured S3 client
    def client
      args = {
        region: region,
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        force_path_style: true
      }
      args[:endpoint] = endpoint unless endpoint.nil?
      Aws::S3::Client.new(args)
    end

    # Returns a list of all keys in the given bucket with an optional prefix
    #
    # Note: This always hits the S3 GET Bucket API - no data is cached
    def keys(bucket, prefix = "")
      make_bucket(bucket)
      client.list_objects_v2(
        bucket: bucket,
        prefix: prefix
      ).contents.map(&:key)
    end

    # Creates the named bucket if it doesn't exist
    def make_bucket(bucket)
      # Don't spam S3 unless this is the first time checking this bucket
      return if @bucket_exists[bucket]
      @bucket_exists[bucket] = true

      client.head_bucket(bucket: bucket)
    rescue Aws::S3::Errors::NotFound
      client.create_bucket(bucket: bucket)
    end

    def url_to_key(url)
      url.path.delete_prefix('/')
    end

    # Returns an S3 object at the given (fake) URL.  The hostname contains the
    # bucket, which the path, once stripped of the preceding slash, is the
    # object's key.
    #
    # Note: this always hits the S3 GET Object API - no data is cached
    def object(url)
      make_bucket(url.host)
      s3 = Aws::S3::Resource.new(client: client)
      bucket = s3.bucket(url.host)
      bucket.object(url_to_key(url))
    end

    def object_exists?(url)
      make_bucket(url.host)
      s3 = Aws::S3::Resource.new(client: client)
      client.head_object(bucket: url.host, key: url_to_key(url))
      true
    rescue Aws::S3::Errors::NotFound
      false
    end
  end
end
