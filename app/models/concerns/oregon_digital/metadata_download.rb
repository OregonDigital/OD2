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
          from_controlled_field(label)
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

    def from_controlled_field(label)
      # FETCH: Get the SolrDocument that store the label$uri
      cv_values = SolrDocument.find(id)

      # GET: Get the parse value out of the label$uri
      parse_cv_values = cv_values.label_uri_helpers(label)

      # MAP: Map out the value and return a string of labels
      parse_cv_values.map { |cv| !cv['label'].empty? ? cv['label'] : "No label found [#{cv['uri']}]" }.join('|')
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
  end
end
