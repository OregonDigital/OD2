# frozen_string_literal:true

module OregonDigital::Derivatives::Document
  # Processor is OD's derivative processor for Document types, overridden to
  # give us control over how PDFs are converted to JPGs since that's done in a
  # broken way in Hyrax core (it's not compatible with using MiniMagick with
  # GraphicsMagick)
  class Processor < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    def self.encode(path, format, outdir)
      execute "#{Hydra::Derivatives.libreoffice_path} --invisible --headless \
        --convert-to #{format} \
        --outdir #{outdir} \
        #{Shellwords.escape(path)}"
    end

    # Converts the document to the format specified in the directives hash.
    # TODO: file_suffix and options are passed from ShellBasedProcessor.process but are not needed.
    #       A refactor could simplify this.
    def encode_file(_file_suffix, _options = {})
      convert_to_format
    ensure
      FileUtils.rm_f(converted_file)
    end

    private

    # For jpeg files, a pdf is created from the original source and then passed to the Image processor class
    # so we can get a better conversion with resizing options. Otherwise, the ::encode method is used.
    def convert_to_format
      if directives.fetch(:format) == 'jpg'
        OregonDigital::Derivatives::Image::GMProcessor.new(converted_file, directives).process
      else
        output_file_service.call(File.read(converted_file), directives)
      end
    end

    def converted_file
      @converted_file ||= if directives.fetch(:format) == 'jpg'
                            convert_to('pdf')
                          else
                            convert_to(directives.fetch(:format))
                          end
    end

    def convert_to(format)
      self.class.encode(source_path, format, Hydra::Derivatives.temp_file_base)
      File.join(Hydra::Derivatives.temp_file_base, [File.basename(source_path, '.*'), format].join('.'))
    end
  end
end
