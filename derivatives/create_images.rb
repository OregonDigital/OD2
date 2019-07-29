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

  S3.object(u).upload_file(out)
end
