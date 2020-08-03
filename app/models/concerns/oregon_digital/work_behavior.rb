# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets base behaviors for all works
  module WorkBehavior
    extend ActiveSupport::Concern
    include OregonDigital::AccessControls::Visibility

    included do
      before_save :resolve_oembed_errors
      validates_presence_of %i[title resource_type rights_statement identifier]
    end

    def graph_fetch_failures
      @graph_fetch_failures ||= []
    end

    # Export work metadata as CSV string
    def csv_metadata
      # Build a CSV of label headers and metadata value data
      props = properties_as_s.merge(controlled_properties_as_s)

      ::CSV.generate do |csv|
        csv << props.keys
        csv << props.values
      end
    end

    # Gather work files and csv metadata and return it zipped together
    def zip_files
      csv_string = csv_metadata

      # Create zip file as StringIO object
      Zip::OutputStream.write_buffer do |zio|
        # Add the metadata
        zio.put_next_entry('metadata.csv')
        zio.write csv_string

        # Add each file
        file_sets.each do |file_set|
          file = file_set.files.first

          copy_file_to_zip(file, zio)
        end
      end
    end

    # TODO: Implement low resolution download
    def zip_files_low
      zip_files
    end

    private

    def copy_file_to_zip(file, zio)
      file_name = file.file_name.first
      url = file.uri.value

      zio.put_next_entry(file_name)
      # Copy file contents directly from Fedora HTTP response
      URI.open(url) do |io|
        IO.copy_stream(io, zio)
      end
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
      prop = prop.solrize.second.nil? ? [prop.solrize.first, 'No label found'] : prop.solrize[1][:label].split('$')
      prop[1] = "[#{prop[1]}]"
      prop.join(' ')
    end
  end
end
