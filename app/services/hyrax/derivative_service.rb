# frozen_string_literal:true

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

  def initialize(file_set)
    self.services ||= [Hyrax::FileSetDerivativesService]
    @file_set = file_set
    @valid_services = self.services.map { |s| s.new(file_set) }.select(&:valid?)
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
