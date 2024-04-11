# frozen_string_literal:true

module OregonDigital::Derivatives::Document
  # Tells hydra which processor to use for openjp2 processing
  class TesseractRunner < Hydra::Derivatives::FullTextExtract
    def self.processor_class
      TesseractProcessor
    end
  end
end