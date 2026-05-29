ActiveSupport::Reloader.to_prepare do
  Hydra::Derivatives.config.output_file_service = Hyrax::PersistDerivatives
  Hydra::Derivatives.config.source_file_service = Hyrax::LocalFileService
  Hydra::Derivatives::FullTextExtract.output_file_service = OregonDigital::PersistDirectlyContainedOutputFileService
end
