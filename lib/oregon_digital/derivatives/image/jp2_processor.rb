# frozen_string_literal:true

require 'mini_magick'
require 'tempfile'

module OregonDigital::Derivatives::Image
  # OpenJP2 processor for derivatives
  class JP2Processor < Hydra::Derivatives::Processors::Processor
    include Hydra::Derivatives::Processors::ShellBasedProcessor

    class << self
      attr_writer :opj_compress, :opj_decompress

      def opj_compress
        @opj_compress ||= 'opj_compress'
      end

      def opj_decompress
        @opj_decompress ||= 'opj_decompress'
      end

      def opj_compress_recipe(args, long_dim)
        if args[:recipe].is_a? String
          args[:recipe]
        else
          calculate_recipe(args, long_dim)
        end
      end

      def calculate_recipe(args, long_dim)
        levels_arg = args.fetch(:levels, level_count_for_size(long_dim))
        rates_arg = args.fetch(:compression, 10)
        tile_size = args.fetch(:tile_size, 1024)
        tiles_arg = "#{tile_size},#{tile_size}"

        "-n #{levels_arg} -r #{rates_arg} -t #{tiles_arg}"
      end

      def level_count_for_size(long_dim)
        1 + Math.log2(long_dim / 96).floor
      end

      def encode(path, recipe, output_file)
        execute "#{opj_compress} \
          -i #{Shellwords.escape(path)} \
          -o #{output_file} #{recipe}"
      end
    end

    def calc_long_dim(image)
      [image[:width], image[:height]].max
    end

    def image
      @image ||= MiniMagick::Image.open(source_path)
    end

    def image_recipe
      self.class.opj_compress_recipe(directives, calc_long_dim(image))
    end

    def free_image
      return if @image.nil?

      @image.destroy!
    end

    def process
      OregonDigital::Derivatives::Image::Utils.tmp_file('jp2') do |out_path|
        self.class.encode(source_path, image_recipe, out_path)
        output_file_service.call(File.open(out_path, 'rb'), directives)
      end

      free_image
    end
  end
end
