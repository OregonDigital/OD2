# frozen_string_literal: true

module Hyrax
  # OVERRIDDEN: we need to send everything related to derivative paths in to
  # our S3-based (and reusable, not Hyrax-only) derivative path class.
  class DerivativePath
    attr_reader :id, :destination_name

    class << self
      # Path on file system where derivative file is stored
      # @param [ActiveFedora::Base or String] object either the AF object or its id
      # @param [String] destination_name
      def derivative_path_for_reference(object, destination_name)
        new(object, destination_name).derivative_path
      end

      # @param [ActiveFedora::Base or String] object either the AF object or its id
      # @return [Array<String>] Array of paths to derivatives for this object.
      def derivatives_for_reference(object)
        new(object).all_paths
      end
    end

    # @param [ActiveFedora::Base, String] object either the AF object or its id
    # @param [String] destination_name
    def initialize(object, destination_name = nil)
      @id = object.is_a?(String) ? object : object.id
      @destination_name = destination_name.gsub(/^original_file_/, '') if destination_name
    end

    def derivative_path
      path_factory.url(label: destination_name)
    end

    # Returns all known derivatives' paths for the object
    def all_paths
      path_factory.all_urls
    end

    private

    def path_factory
      OregonDigital::DerivativePath.new(bucket: ENV['AWS_S3_DERIVATIVES_BUCKET'], id: id)
    end
  end
end
