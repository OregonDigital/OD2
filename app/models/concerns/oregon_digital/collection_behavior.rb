# frozen_string_literal:true

require 'csv'

module OregonDigital
  # Sets additional behaviors for collections
  module CollectionBehavior
    extend ActiveSupport::Concern

    # Zip up all works in collection into one collection zip
    def zip_files(current_ability)
      Zip::OutputStream.write_buffer do |zio|
        # Add the metadata
        zio.put_next_entry('metadata.csv')
        zio.write csv_metadata

        copy_works_to_zip(child_works, current_ability, zio)
        copy_collections_to_zip(child_collections, current_ability, zio)
      end
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

    private

    def copy_works_to_zip(works, current_ability, zio)
      works.each do |work|
        # Skip adding works that the user can't download
        next unless current_ability.can? :download, work

        zio.put_next_entry("#{work.id}.zip")
        zio.write work.zip_files.string
      end
    end

    def copy_collections_to_zip(collections, current_ability, zio)
      collections.each do |collection|
        # Skip adding collections that the user can't see
        next unless current_ability.can? :show, collection

        zio.put_next_entry("#{collection.id}.zip")
        zio.write collection.zip_files(current_ability).string
      end
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
