class OembedError < ApplicationRecord
  serialize :oembed_errors, Array

  validates_presence_of :document_id

  # Make errors a unique array and touch this object to update updated_at
  before_save :unique_errors

  # Make sure oembed_errors initializes as an array
  def initialize(attributes={})
    super
    @document_id ||= attributes[:document_id]
    @oembed_errors ||= [attributes[:oembed_error]]
  end

  # Store errors as a symbol/string and we only want unique errors to avoid stacking
  # up a bunch of the same error
  def unique_errors
    self.oembed_errors = self.oembed_errors.map(&:to_s).uniq
    self.touch if self.persisted?
  end
end
