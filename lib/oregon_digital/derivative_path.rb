# frozen_string_literal: true

module OregonDigital
  # DerivativePath houses all our common logic for determining where to find
  # derivatives for a given fileset ID
  class DerivativePath
    attr_reader :bucket, :id

    def initialize(bucket:, id:)
      @bucket = bucket
      @id = id
    end

    # Returns the URL to create or find any derivative based on its fileset,
    # extension, and, optionally, sequence number
    def url(label:, sequence: 0)
      parts = [prefix, label]
      parts.push(format('%04d', sequence)) if sequence.positive?
      URI(parts.join('-') + '.' + ext_for(label))
    end

    # Returns all URLs with the same prefix, effectively returning a full list
    # of derivatives for the fileset id
    #
    # Note: This hits S3's GET Bucket service with the fileset id's prefix
    def all_urls
      s3_factory.keys(bucket, pathify_id.join('/')).collect {|key| [url_base, key].join('/')}
    end

    def sorted_derivative_urls(label)
      all_urls.select {|url| File.extname(url) == ext_for(label)}
    end

    # Returns true if the given asset exists in our data store
    #
    # Note: This hits S3's GET Bucket service with the fileset id's prefix
    def exist?(label:, sequence: 0)
      s3_factory.object_exists?(url(label: label, sequence: sequence))
    end

    private

    # Returns slash-delimited groups for an object with the given id
    def pathify_id
      id.split('').each_slice(2).map(&:join)
    end

    # Returns the base prefix for the fileset's derivatives, to be suffixed
    # with the filename, sequence number, and extension
    def prefix
      [url_base, *pathify_id].join('/')
    end

    def url_base
      "s3://#{bucket}"
    end

    # Returns the extension for a given label.  Most of the time, this is just
    # the label itself, but some labels have special extensions, such as
    # 'thumbnail' always being a JPG.
    def ext_for(label)
      case label
      when 'thumbnail' then 'jpg'
      when 'zoomable'  then 'jp2'
      else                  label
      end
    end

    def s3_factory
      OregonDigital::S3.new(
        endpoint:          ENV['S3_URL'],
        region:            ENV['AWS_S3_REGION'],
        access_key_id:     ENV['AWS_S3_APP_KEY'],
        secret_access_key: ENV['AWS_S3_APP_SECRET']
      )
    end
  end
end
