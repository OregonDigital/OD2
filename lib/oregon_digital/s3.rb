# frozen_string_literal: true

module OregonDigital
  # S3 houses all our common AWS S3 logic / setup in a framework-agnostic way
  # so we can include this code in the derivatives services and the main OD app
  class S3
    attr_reader :endpoint, :region, :access_key_id, :secret_access_key

    # Returns an instance of OregonDigital::S3 using the environment for all
    # necessary configuration
    def self.instance
      OregonDigital::S3.new(
        endpoint: ENV['S3_URL'],
        region: ENV['AWS_S3_REGION'],
        access_key_id: ENV['AWS_S3_APP_KEY'],
        secret_access_key: ENV['AWS_S3_APP_SECRET']
      )
    end

    def initialize(endpoint: nil, region:, access_key_id:, secret_access_key:)
      @endpoint = endpoint
      @region = region
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @bucket_exists = {}
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

    def resource
      Aws::S3::Resource.new(client: client)
    end

    # Returns a list of all keys in the given bucket with an optional prefix
    #
    # Note: This always hits the S3 GET Bucket API - no data is cached
    def keys(bucket, prefix = '')
      create_bucket_if_not_exist(bucket)
      client.list_objects_v2(
        bucket: bucket,
        prefix: prefix
      ).contents.map(&:key)
    end

    # Creates the named bucket if it doesn't exist
    def create_bucket_if_not_exist(name)
      b = resource.bucket(name)
      create_bucket(name) unless b.exists?
    end

    def create_bucket(name)
      client.create_bucket(bucket: name)
    end

    def url_to_key(url)
      url.path.delete_prefix('/')
    end

    # Returns an S3 object at the given (fake) URL.  The hostname contains the
    # bucket, which the path, once stripped of the preceding slash, is the
    # object's key.
    def object(url)
      create_bucket_if_not_exist(url.host)
      bucket = resource.bucket(url.host)
      bucket.object(url_to_key(url))
    end

    def object_exists?(url)
      create_bucket_if_not_exist(url.host)
      client.head_object(bucket: url.host, key: url_to_key(url))
      true
    rescue Aws::S3::Errors::NotFound
      false
    end
  end
end
