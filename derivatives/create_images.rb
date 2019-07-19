# frozen_string_literal: true

def create_thumbnail(bmp_path, destination)
  derive(bmp_path, destination, 'jpg') do |out|
    shell('gm', 'convert', bmp_path, '-flatten', '-resize', '120x120>', out)
  end
end

def create_zoomable(bmp_path, destination)
  derive(bmp_path, destination, 'jp2') do |out|
    shell('opj_compress', '-i', bmp_path, '-o', out, '-t', '1024,1024', '-r', '20', '-n', '6')
  end
end

# Generates a filename based on the source file and the extension, yields that
# file to the caller to create a derivative, then uploads the derivative to S3.
def derive(source, destination, extension)
  # Get rid of the scheme, which we require to be S3
  u = URI(destination)
  raise ArgumentError if u.scheme != 's3'

  out = "#{source}.#{extension}"
  yield out

  s3_object(u).upload_file(out)
end

def s3_object(url)
  warn url.inspect

  s3 = Aws::S3::Resource.new(client: s3_client_factory)
  bucket = s3.bucket(url.host)
  raise %(Unable to find AWS bucket "#{bucket}") if bucket.nil?

  # We have to strip the leading slash because URIs have absolute paths, but S3
  # wants a key, not a path
  bucket.object(url.path.sub(/^\//, ''))
end

def s3_client_factory
  endpoint = ENV['S3_URL'].empty? ? nil : ENV['S3_URL']
  Aws::S3::Client.new(
    endpoint: endpoint,
    region: ENV['AWS_S3_REGION'],
    access_key_id: ENV['AWS_S3_APP_KEY'],
    secret_access_key: ENV['AWS_S3_APP_SECRET'],
    force_path_style: true
  )
end
