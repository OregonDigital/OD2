# frozen_string_literal:true

module OregonDigital::Derivatives::Image
  # Tells hydra which processor to use for graphicsmagick processing
  class GMRunner < Hydra::Derivatives::Runner
    def self.processor_class
      GMProcessor
    end
  end
end
