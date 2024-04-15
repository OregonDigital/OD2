# frozen_string_literal: true

Rails.application.config.to_prepare do
  Bulkrax::ObjectFactoryInterface.class_eval do
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
  end
end