# frozen_string_literal:true

require 'mini_magick'

module OregonDigital::Derivatives::Image
  # GraphicsMagick processor for derivatives
  class GMProcessor < Hydra::Derivatives::Processors::Processor
    class_attribute :timeout

    def process
      timeout ? process_with_timeout : create_image
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_image }
    rescue Timeout::Error
      raise Hydra::Derivatives::TimeoutError, "Unable to process image \
        derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    def create_image
      image = load_image(source_path)
      OregonDigital::Derivatives::Image::Utils.tmp_file(format) do |out_path|
        convert(image, out_path)
        output_file_service.call(File.open(out_path, 'rb'), directives)
      end
      @tmp_image.destroy!
    end

    def load_image(path)
      @tmp_image = MiniMagick::Image.open(path)
      selected_layers(@tmp_image)
    end

    def convert(image, outfile)
      MiniMagick::Tool::Convert.new do |cmd|
        cmd << image.path
        apply_convert_commands(cmd)
        cmd << "#{format}:#{outfile}"
      end
    end

    def apply_convert_commands(cmd)
      if size
        cmd.flatten
        cmd.resize(size)
      end
      cmd.quality(quality.to_s) if quality
    end

    def size
      directives.fetch(:size, nil)
    end

    def quality
      directives.fetch(:quality, nil)
    end

    def format
      directives.fetch(:format, 'jpg')
    end

    def selected_layers(image)
      if image.type.match?(/pdf/i)
        image.layers[directives.fetch(:layer, 0)]
      elsif directives.fetch(:layer, false)
        image.layers[directives.fetch(:layer)]
      else
        image
      end
    end
  end
end
