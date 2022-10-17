# frozen_string_literal: true

# Set up local processing
module Bulkrax::Concerns::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local; end
end
