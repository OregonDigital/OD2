# frozen_string_literal:true

module OregonDigital
  # Overrides the Hyrax derivative generation for our JP2 setup
  #
  # This builds JP2 derivatives in stages.  The openjpeg tools can't convert
  # many formats to JP2 directly, so we make sure we have a BMP, and then
  # convert that to JP2.  It's a bit messy and definitely inelegant, but it
  # does the job.
  #
  # We also have to implement graphicsmagick-based processing to deal with the
  # intermediary image conversions.  The Hyrax code uses MiniMagick, which
  # doesn't work with graphicsmagick when trying to flatten an image, which
  # Hyrax does on resize operations.  We could use ImageMagick, but for some
  # reason it's got a limit on image size.  Huge images (say 400 megapixels)
  # just cannot be read by it.  That may not be a problem today, but it could
  # become one eventually.
  #
  # We subclass from Hyrax::FileSetDerivativesService so that we can define a
  # single derivative service - if we have two services listed, Hyrax will fire
  # off both, not just the first one that is successful.  So we need our JP2
  # processing to replace the standard processor, while still holding onto the
  # built-in Hyrax processors for derivative types we don't need to customize.
  class FileSetDerivativesService < Hyrax::FileSetDerivativesService
    def create_derivatives(filename)
      # This is really stupid, but rubocop actually sees this alias as being
      # significantly simpler than just having "file_set.class" in the lines
      # below
      fsc = file_set.class

      case mime_type
      when *fsc.pdf_mime_types             then create_pdf_derivatives(filename)
      when *fsc.office_document_mime_types then create_office_document_derivatives(filename)
      when *fsc.audio_mime_types           then create_audio_derivatives(filename)
      when *fsc.video_mime_types           then create_video_derivatives(filename)
      when *fsc.image_mime_types           then create_image_derivatives(filename)
      end
    end

    # Returns the path to a derivative in a sequence, or just the raw path if no sequence is desired
    def sequence_path(path, sequence = nil)
      return path unless sequence

      ext = File.extname(path)
      dirname = File.dirname(path)
      path_no_ext = File.join(dirname, File.basename(path, ext))
      format('%<noext>s-%<sequence>04d%<ext>s', noext: path_no_ext, sequence: sequence, ext: ext)
    end

    # The destination_name parameter has to match up with the file parameter
    # passed to the DownloadsController
    def derivative_url(destination_name, sequence = nil)
      path = derivative_path_factory.derivative_path_for_reference(file_set, destination_name)
      seq_path = sequence_path(path, sequence)
      URI("file://#{seq_path}").to_s
    end

    # Returns a sorted list of all derivatives of the given name (typically a sequence)
    def sorted_derivative_urls(destination_name)
      path = derivative_path_factory.derivative_path_for_reference(file_set, destination_name)
      ext = File.extname(path)
      paths = derivative_path_factory.derivatives_for_reference(file_set).select do |derivative|
        File.extname(derivative) == ext
      end
      paths.collect { |pth| URI("file://#{pth}").to_s }.sort
    end

    # Overridden: we need our image derivatives to be 100% done our way, not the Hyrax way
    def create_image_derivatives(filename)
      OregonDigital::Derivatives::Image::Utils.tmp_file('bmp') do |out_path|
        preprocess_image(filename, out_path)
        create_thumbnail(out_path)
        create_zoomable(out_path)
      end
    end

    def create_pdf_derivatives(filename)
      create_thumbnail(filename)
      extract_full_text(filename, uri)

      # Open the PDF - this creates a tempfile because of how MiniMagick works,
      # so we immediately destroy the object after retrieving the page count
      pdf = MiniMagick::Image.open(filename)
      page_count = pdf.pages.length
      pdf.destroy!

      0.upto(page_count - 1) do |pagenum|
        OregonDigital::Derivatives::Image::Utils.tmp_file('bmp') do |out_path|
          manual_convert(filename, pagenum, out_path)
          create_zoomable_page(out_path, pagenum)
        end
      end
    end

    def create_thumbnail(filename)
      OregonDigital::Derivatives::Image::GMRunner.create(filename,
                                                         outputs: [{ label: :thumbnail,
                                                                     size: '120x120>',
                                                                     format: 'jpg',
                                                                     url: derivative_url('thumbnail'),
                                                                     layer: 0 }])
    end

    def create_zoomable(filename)
      create_zoomable_page(filename, nil)
    end

    def create_zoomable_page(filename, pagenum)
      OregonDigital::Derivatives::Image::JP2Runner.create(filename,
                                                          outputs: [{ label: :jp2,
                                                                      mime_type: mime_type,
                                                                      url: derivative_url('jp2', pagenum),
                                                                      tile_size: '1024',
                                                                      compression: '20',
                                                                      layer: 0 }])
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
    def preprocess_image(source_file, temp_bmp_path)
      case mime_type
      when 'image/jp2' then jp2_to_bmp(source_file, temp_bmp_path)
      when 'image/bmp' then bmp_to_bmp(source_file, temp_bmp_path)
      else                  other_to_bmp(source_file, temp_bmp_path)
      end
    end

    def jp2_to_bmp(source, dest)
      source = Shellwords.escape(source)
      dest = Shellwords.escape(dest)
      bin = jp2_processor.opj_decompress
      jp2_processor.execute "#{bin} -i #{source} -o #{dest}"
    end

    def bmp_to_bmp(source, dest)
      File.unlink(dest)
      FileUtils.ln_s(source, dest)
    end

    def other_to_bmp(source, dest)
      image = MiniMagick::Image.open(source)
      image.depth(8).format('bmp').write(dest)

      # The above code generates a temp file which we don't need beyond the
      # .write() call, so we explicitly destroy the image object
      image.destroy!
    end

    def manual_convert(filename, pagenum, out_path)
      MiniMagick::Tool::Convert.new do |cmd|
        cmd.density(300)
        cmd << format('%<filename>s[%<page>d]', filename: filename, page: pagenum)
        cmd.depth(8)
        cmd << out_path
      end
    end

    # Returns the JP2Processor class of choice
    def jp2_processor
      OregonDigital::Derivatives::Image::JP2Processor
    end
  end
end
