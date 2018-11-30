# frozen_string_literal:true

module OregonDigital::Derivatives::Image
  # Tells hydra which processor to use for openjp2 processing
  class JP2Runner < Hydra::Derivatives::Runner
    def self.processor_class
      JP2Processor
    end
  end
end
