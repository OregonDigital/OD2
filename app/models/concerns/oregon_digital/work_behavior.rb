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

    # creates a temporary file in tmp/works/metadata
    def csv_metadata
      dir = Rails.root.join('tmp', 'works', 'metadata')
      FileUtils.mkdir_p dir
      Tempfile.open(id, dir) do |f|
        all_props, all_values = properties_to_s

        csv_string = CSV.generate do |csv|
          csv << all_props
          csv << all_values
        end

        f << csv_string
      end
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

    def properties_to_s
      all_props = []
      all_values = []
      rejected_fields = %w[head tail]

      properties.map do |label, _field|
        values = send(label)
        next if values.blank? || rejected_fields.include?(label)

        all_props << label
        all_values << (values.respond_to?(:to_a) ? values.map(&:to_s).join('|') : values)
      end
      [all_props, all_values]
    end
  end
end
