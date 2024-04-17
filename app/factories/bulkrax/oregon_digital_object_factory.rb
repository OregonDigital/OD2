# frozen_string_literal: true

module Bulkrax
  # Object factory
  class OregonDigitalObjectFactory < ObjectFactory
    # Override to add the _attributes properties
    def permitted_attributes
      attribute_properties + super
    end

    # Gather the attribute_properties
    def attribute_properties
      klass.properties.keys.map { |k| "#{k}_attributes".to_sym unless klass.properties[k].class_name.nil? }.compact
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create
      attrs = transform_attributes
      attrs['full_size_download_allowed'] = attrs['full_size_download_allowed'].to_i
      @object = klass.new
      conditionally_set_reindex_extent
      run_callbacks :save do
        run_callbacks :create do
          if klass == Bulkrax.collection_model_class
            create_collection(attrs)
          elsif klass == Bulkrax.file_model_class
            create_file_set(attrs)
          else
            create_work(attrs)
          end
        end
      end

      apply_depositor_metadata
      log_created(object)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
