# frozen_string_literal:true

# Runs the derivatives job for images, generating a thumbnail and a JP2
class CreateImageDerivativesJob
  include Sidekiq::Worker

  def perform(id, source, mimetype)
    # We literally create a tempfile just to get a filename we know won't be in
    # use.  We use the id in addition to the Tempfile magic because there is an
    # incredibly tiny chance another call to Tempfile.new after our unlink
    # but before our preprocess_image call will cause problems.  Despite the
    # absurdly low odds, knowing my luck, it will happen in production and
    # screw up something incredibly important.  Adding the id should make this
    # about as fault-tolerant as one can hope for.  From Ruby.
    tempfile = Tempfile.new(["deriv-#{id}", '.bmp'])
    tempbmp = tempfile.path
    tempfile.close
    tempfile.unlink

    preprocess_image(source, mimetype, tempbmp)
    thumb = derivative_path_factory(id).url(label: 'thumbnail')
    create_thumbnail(tempbmp, thumb)
    zoom = derivative_path_factory(id).url(label: 'zoomable')
    create_zoomable(tempbmp, zoom)

    queue_update_job(id)
  end

  # Queues up the job for Hyrax to take control again and update the fileset
  def queue_update_job(id)
    Sidekiq::Client.new.push(
      'queue' => 'default',
      'class' => 'UpdateFilesetJob',
      'args' => [id]
    )
  end

  private

  def derivative_path_factory(id)
    OregonDigital::DerivativePath.new(bucket: S3Bucket, id: id)
  end

  # Pre-processes the given file to generate a BMP based on its mime type:
  #
  # - JP2s need to be decoded and then re-encoded by opj tools:
  #   GraphicsMagick can't read them, and opj_compress won't re-encode an
  #   existing JP2....
  # - BMPs don't need an intermediate step, so they don't need any
  #   preprocessing to happen; we fake it by hard-linking the existing BMP
  #   so the rest of the logic works consistently
  # - All other images need to be converted to BMP via graphicsmagick
  def preprocess_image(source_file, mimetype, temp_bmp_path)
    case mimetype
    when 'image/jp2' then jp2_to_bmp(source_file, temp_bmp_path)
    when 'image/bmp' then bmp_to_bmp(source_file, temp_bmp_path)
    else                  other_to_bmp(source_file, temp_bmp_path)
    end
  end

  def jp2_to_bmp(source, dest)
    shell('opj_decompress', '-i', source, '-o', dest)
  end

  def bmp_to_bmp(source, dest)
    File.unlink(dest) if File.exist?(dest)
    FileUtils.ln_s(source, dest)
  end

  def other_to_bmp(source, dest)
    shell('gm', 'convert', source, dest)
  end
end
