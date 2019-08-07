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

    # Generate a temporary CSV export and return file pointer
    def csv_metadata
      # Build a CSV of label headers and metadata value data
      props = properties_as_s.merge(controlled_properties_as_s)

      csv_string = CSV.generate do |csv|
        csv << props.keys
        csv << props.values
      end

      # Creates a temporary file in tmp/works/metadata
      dir = Rails.root.join('tmp', 'works', 'metadata')
      FileUtils.mkdir_p dir
      Tempfile.open(id, dir) do |f|
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

    # Convert work properties to hash of machine_label=>human_value
    def properties_as_s
      props = {}
      rejected_fields = %w[head tail]

      properties.map do |label, _field|
        values = send(label)
        next if values.blank? || rejected_fields.include?(label) || controlled_properties.include?(label.to_sym)

        props[label] = (values.respond_to?(:to_a) ? values.map(&:to_s).join('|') : values)
      end
      props
    end

    # Convert work controlled vocabulary properties to hash of machine_label=>human_value
    def controlled_properties_as_s
      props = {}

      controlled_properties.map do |label, _field|
        values = send(label)
        next if values.blank?

        values = values.map { |prop| controlled_property_to_csv_value(prop) }

        props[label] = values.map(&:to_s).join('|')
      end
      props
    end

    # Convert work controlled property value to '<label> [<uri>]' format
    def controlled_property_to_csv_value(prop)
      prop.fetch
      prop = prop.solrize[1][:label].split('$')
      prop[1] = "[#{prop[1]}]"
      prop.join(' ')
    end
  end
end
