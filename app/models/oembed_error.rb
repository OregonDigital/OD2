# frozen_string_literal:true

# String errors related to oEmbed links
class OembedError < ApplicationRecord
  serialize :oembed_errors, Array

  validates_presence_of :document_id

  # Make errors a unique array
  before_save :unique_errors
  after_save :alert_depositor

  # Make sure oembed_errors initializes as an array
  def initialize(document_id, oembed_error = nil)
    super()
    @document_id ||= document_id
    @oembed_errors ||= [oembed_error]
  end

  def add_error(error)
    oembed_errors << error unless oembed_errors.include? error
    save
  end

  private

  # Store errors as a symbol/string and we only want unique errors to avoid
  # stacking up a bunch of the same error
  def unique_errors
    oembed_errors.map!(&:to_s).uniq!
  end

  def alert_depositor
    # Only alert user if new errors are added
    return unless saved_change_to_oembed_errors?

    user = User.find_by_user_key(Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: document_id).depositor)
    Hyrax.config.callback.run(:after_oembed_error, user, oembed_errors)
  end
end
