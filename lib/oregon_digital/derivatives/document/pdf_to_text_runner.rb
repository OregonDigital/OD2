# frozen_string_literal:true

module OregonDigital::Derivatives::Document
  # Tells hydra which processor to use for openjp2 processing
  class PDFToTextRunner < Hydra::Derivatives::FullTextExtract
    def self.processor_class
      PDFToTextProcessor
    end
  end
end
