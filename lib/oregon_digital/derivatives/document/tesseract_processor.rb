# frozen_string_literal:true

require 'mini_magick'
require 'tempfile'

module OregonDigital::Derivatives::Document
  # OpenJP2 processor for derivatives
  class TesseractProcessor < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    class << self

      def encode(path, recipe, output_file)
        out_file = out_path_without_extension(output_file)
        execute "tesseract #{path.to_s} #{out_file.to_s} -l eng hocr"
      end

    end

    def out_path_without_extension(file_path)
      filename = File.basename(file_path,File.extname(file_path))
      [File.dirname(file_path), filename].join('/')
    end

    def process
      OregonDigital::Derivatives::Image::Utils.tmp_file('hocr') do |out_path|
        self.class.encode(source_path, out_path)
        byebug
        output_file_service.call(File.open(out_path, 'rb'), directives)
      end
    end
  end
end
