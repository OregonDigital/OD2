# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets additional behaviors for collections
  module MetadataDownload
    extend ActiveSupport::Concern

    # Export metadata as a CSV string
    # rubocop:disable Metrics/MethodLength
    def metadata_row(keys, controlled_keys)
      keys.map do |label|
        values = try(label)
        next if values.nil?

        if (service = local_metadata_authority_service(label))
          from_local_authority(service, Array(values))
        elsif controlled_keys.include?(label.to_sym)
          from_controlled_field(values)
        elsif values.respond_to?(:map)
          values.map(&:to_s).join('|')
        else
          values
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def from_local_authority(service, values)
      values.map { |prop| service.label prop }.join('|')
    end

    def from_controlled_field(values)
      values.map { |prop| controlled_property_to_csv_value(prop).to_s }.join('|')
    end

    def local_metadata_authority_service(key)
      suppress(KeyError) do
        @label_services ||= [
          OregonDigital::LanguageService.new,
          Hyrax.config.license_service_class.new,
          Hyrax::ResourceTypesService,
          Hyrax.config.rights_statement_service_class.new
        ]
        @label_services.find { |service| service.authority.subauthority == key.to_s.pluralize }
      end
    end

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
