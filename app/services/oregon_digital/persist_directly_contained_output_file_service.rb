# frozen_string_literal: true

module OregonDigital
  # This Service is an implementation of the Hydra::Derivatives::PersistOutputFileService
  # It supports directly contained files
  class PersistDirectlyContainedOutputFileService < Hyrax::PersistDirectlyContainedOutputFileService
    # Override this implementation if you need a remote file from a different location
    # @param file_set [FileSet] the container of the remote file
    # @param directives [Hash] directions which can be used to determine where to persist to
    # @option directives [String] container Name of the container association.
    # @return [ActiveFedora::File]
    def self.retrieve_remote_file(file_set, directives)
      file_set.association(directives.fetch(:container).to_sym).build
    end
    private_class_method :retrieve_remote_file
  end
end
