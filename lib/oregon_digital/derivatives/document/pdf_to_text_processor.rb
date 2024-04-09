# frozen_string_literal:true

require 'mini_magick'
require 'tempfile'

module OregonDigital::Derivatives::Document
  # OpenJP2 processor for derivatives
  class PDFToTextProcessor < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    class << self
      def encode(path, output_file)
        out_file = out_path_without_extension(output_file)
        system('pdftotext', '-bbox', path.to_s, output_file.to_s, out: File::NULL, err: File::NULL)
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
      OregonDigital::Derivatives::Image::Utils.tmp_file('ocr') do |out_path|
        self.class.encode(source_path, out_path)
        file_content = File.read(out_path)
        # extracted text is derived from original PDF and isn't scaled when derivatives are created
        scale_factor = 4.175
        bbox_content = Nokogiri::HTML(file_content)
        bbox_content.css('word').each do |word|
          word['xmin'] = word['xmin'].to_i * scale_factor
          word['xmax'] = word['xmax'].to_i * scale_factor
          word['ymin'] = word['ymin'].to_i * scale_factor
          word['ymax'] = word['ymax'].to_i * scale_factor
        end
        output_file_service.call(file_content, directives)
      end
    end
  end
end
