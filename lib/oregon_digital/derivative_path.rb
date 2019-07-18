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
    # of derivatives for the fileset id.  This hits S3's GET Bucket service.
    def all_urls
      raise NotImplementedError
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
  end
end
