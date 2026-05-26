Rails.application.config.to_prepare do
  Bulkrax::ImportersHelper.module_eval do
    # borrowed from batch-importer https://github.com/samvera-labs/hyrax-batch_ingest/blob/main/app/controllers/hyrax/batch_ingest/batches_controller.rb
    def available_admin_sets
      # Restrict available_admin_sets to only those current user can deposit to.
      @available_admin_sets ||= Hyrax::Collections::PermissionsService.source_ids_for_deposit(ability: current_ability, source_type: 'admin_set').map do |admin_set_id|
        [Bulkrax.object_factory.find_or_nil(admin_set_id)&.title&.first || admin_set_id, admin_set_id]
      end
      @available_admin_sets << Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
      @available_admin_sets.flatten
    end
  end
end