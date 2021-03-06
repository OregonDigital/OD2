# frozen_string_literal:true

module OregonDigital::Derivatives::Image
  # Simple derivative utility functions
  class Utils
    class << self
      # Generates a temporary file and passes its path to the given block.  The
      # file is deleted at the end of execution
      def tmp_file(ext)
        f = Tempfile.new(['od2', ".#{ext}"], Hydra::Derivatives.temp_file_base)
        begin
          yield f.path
        ensure
          f.close
          f.unlink
        end
      end

      # Opens the file with minimagick to count pages, destroys the temp files,
      # then returns page count
      def page_count(filename)
        obj = MiniMagick::Image.open(filename)
        page_count = obj.pages.length
        obj.destroy!
        page_count
      end
    end
  end
end
