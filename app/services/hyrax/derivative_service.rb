class Hyrax::DerivativeService
  class_attribute :services

  # OVERRIDDEN: Tried to set an initializer to set this class attribute but that doesn't work when
  # this is run in the context of a background job (CreateDerivativesJob). It seems this full class override
  # is necessary for that reason.
  self.services = [Hyrax::FileSetDerivativesService, OregonDigital::FileSetDerivativesService]
  def self.for(file_set)
    new(file_set)
  end
  attr_reader :file_set
  attr_reader :valid_services
  delegate :mime_type, :uri, to: :file_set
  def initialize(file_set)
    @file_set = file_set
    @valid_services = services.map { |service| service.new(file_set) }.select(&:valid?)
  end

  def cleanup_derivatives
    valid_services.map { |s| s.cleanup_derivatives }
  end

  def create_derivatives(file_path)
    valid_services.map { |s| s.create_derivatives(file_path) }
  end

  def derivative_url(destination_name)
    Hyrax::DerivativePath.derivative_path_for_reference(file_set, destination_name)
  end

  def valid?
    true
  end
end
