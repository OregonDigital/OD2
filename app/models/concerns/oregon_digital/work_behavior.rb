# frozen_string_literal:true

module OregonDigital
  # Sets base behaviors for all works
  module WorkBehavior
    extend ActiveSupport::Concern

    included do
      attr_writer :graph_fetch_failures

      after_save :enqueue_fetch_failures
      before_save :resolve_oembed_errors
    end

    def graph_fetch_failures
      @graph_fetch_failures ||= []
    end

    private

    def enqueue_fetch_failures
      graph_fetch_failures.uniq.each do |rdf_subject|
        enqueue_fetch_failure(rdf_subject)
      end
    end

    ##
    # Returns an RDF::Graph that is stored as a placeholder
    #
    # @param uri [RDF::Uri] the URI to fetch
    # @param [User] the user to alert about this failed fetch
    def enqueue_fetch_failure(uri)
      user = User.find_by_user_key(depositor)
      # Email user about failure
      Hyrax.config.callback.run(:ld_fetch_error, user, uri)

      FetchGraphWorker.perform_in(15.minutes, uri, user)
    end

    # If the oembed_url changed all previous errors are invalid
    def resolve_oembed_errors
      errors = OembedError.find_by(document_id: id)
      errors.delete if oembed_url_changed? && !errors.blank?
    end
  end
end
