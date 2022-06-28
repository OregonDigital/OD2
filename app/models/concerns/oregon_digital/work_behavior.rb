# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets base behaviors for all works
  module WorkBehavior
    extend ActiveSupport::Concern
    include OregonDigital::AccessControls::Visibility

    included do
      validates_presence_of %i[title resource_type rights_statement identifier]
    end

    def graph_fetch_failures
      @graph_fetch_failures ||= []
    end

    # Export work metadata as CSV string
    def csv_metadata
      # Build a CSV of label headers and metadata value data
      props = properties_as_s.merge(controlled_properties_as_s)
      props = props.sort.to_h

      ::CSV.generate do |csv|
        csv << props.keys
        csv << props.values
      end
    end

    private

    # Convert work properties to hash of machine_label=>human_value
    def properties_as_s
      props = {}
      rejected_fields = %w[head tail]

      properties.map do |label, _field|
        values = send(label)
        next if values.blank? || rejected_fields.include?(label) || controlled_properties.include?(label.to_sym)

        props[label.to_sym] = (values.respond_to?(:to_a) ? values.map(&:to_s).join('|') : values)
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
      begin
        prop.fetch
        label = prop.solrize[1][:label].split('$')[0]
      # TriplestoreAdapter::TriplestoreException means no fetch possible
      # NoMethodError likely means the fetch succeeded but no label was actually fetched, this is possible with geonames w/ http
      rescue TriplestoreAdapter::TriplestoreException, NoMethodError
        label = ['No label found', "[#{prop.solrize.first}]"].join(' ')
      end
      label
    end
  end
end
