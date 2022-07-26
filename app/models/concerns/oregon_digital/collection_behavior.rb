# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets additional behaviors for collections
  module CollectionBehavior
    extend ActiveSupport::Concern

    # Export collection metadata as a CSV string
    def metadata_row(keys, controlled_keys)
      keys.map do |label|
        values = try(label)
        if values.nil?
        elsif controlled_keys.include?(label.to_sym)
          values = values.map { |prop| controlled_property_to_csv_value(prop).to_s }.join('|')
        else
          values = (values.respond_to?(:map) ? values.map(&:to_s).join('|') : values)
        end
        values
      end
    end

    private

    # Convert work controlled property value to label
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
