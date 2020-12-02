# frozen_string_literal:true

module OregonDigital::Derivatives::Document
  # Tells hydra which processor to use for document processing
  class Runner < Hydra::Derivatives::Runner
    def self.processor_class
      Processor
    end
  end
end
