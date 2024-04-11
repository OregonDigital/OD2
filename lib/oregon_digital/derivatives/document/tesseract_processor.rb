# frozen_string_literal:true

require 'mini_magick'
require 'tempfile'

module OregonDigital::Derivatives::Document
  # OpenJP2 processor for derivatives
  class TesseractProcessor < Hydra::Derivatives::Processors::FullText
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    class << self
      def encode(path, output_file)
        out_file = out_path_without_extension(output_file)
        execute "tesseract #{path.to_s} #{out_file.to_s} -l eng hocr"
      end

      def out_path_without_extension(file_path)
        filename = File.basename(file_path,File.extname(file_path))
        [File.dirname(file_path), filename].join('/')
      end
    end

    def output_file_service
      OregonDigital::PersistDirectlyContainedOutputFileService
    end

    def process
      OregonDigital::Derivatives::Image::Utils.tmp_file('hocr') do |out_path|
        self.class.encode(source_path, out_path)
        output_file_service.call(File.read(out_path), directives)
      end
    end
  end
end