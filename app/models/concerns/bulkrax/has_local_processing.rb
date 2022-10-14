# frozen_string_literal: true

# test
module Bulkrax
  # test
  module HasLocalProcessing
    # Override the factory to use a customized version
    def factory
      @factory ||= Bulkrax::OregonDigitalObjectFactory.new(parsed_metadata, identifier, replace_files, user, factory_class, update_files)
    end

    # This method is called during build_metadata
    # add any special processing here, for example to reset a metadata property
    # to add a custom property from outside of the import data
    #
    # Transform attribute properties for the factory
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def add_local
      properties_with_classes.each_pair do |key, new_key|
        if parsed_metadata[key].present?
          if parsed_metadata[key].is_a?(String)
            parsed_metadata[new_key]['0'] = { id: parsed_metadata[key] }
          else
            parsed_metadata[new_key] = {}
            parsed_metadata[key].each_with_index do |value, index|
              parsed_metadata[new_key][index.to_s] = { id: value }
            end
          end
          parsed_metadata.delete(key)
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # Return a hash of property : property_attibutes pairs
    def properties_with_classes
      factory_class.properties.keys.map { |k| { k => "#{k}_attributes" } unless factory_class.properties[k].class_name.nil? }.compact.inject(:merge)
    end
  end
end
