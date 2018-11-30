# frozen_string_literal:true

# Helps with the generation of derivatives
class Hyrax::DerivativeService
  class_attribute :services

  # OVERRIDDEN, allow for setting the derivatives in an initializer or using the default
  # TODO: Replace when upstream is refactored/fixed
  def self.for(file_set)
    new(file_set)
  end

  attr_reader :file_set
  attr_reader :valid_services
  delegate :mime_type, :uri, to: :file_set

  # OVERRIDDEN again!  Forcing self.class.services to use our service first.
  # The initializer appears to set the var for hyrax *before* these overrides
  # are loaded, which causes us to lose the setting, which means defaulting to
  # the wrong value....
  def initialize(file_set)
    self.class.services = [OregonDigital::FileSetDerivativesService]
    @file_set = file_set
    @valid_services = self.class.services.map { |s| s.new(file_set) }.select(&:valid?)
    @valid_services.empty? ? self : @valid_services
  end

  def cleanup_derivatives
    valid_services.map(&:cleanup_derivatives)
  end

  def create_derivatives(file_path)
    valid_services.map { |s| s.create_derivatives(file_path) }
  end

  def derivative_url(destination_name)
    Hyrax::DerivativePath.derivative_path_for_reference(file_set, destination_name)
  end

  def valid?
    !valid_services.empty?
  end
end
