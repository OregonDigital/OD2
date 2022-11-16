# frozen_string_literal:true

# For each /dashboard and /admin route, force authorization of depositor, collection curator, or admin
Rails.application.config.to_prepare do
  Admin::OregonDigital::CollectionTypesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::WorkflowsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::AdminSetsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::UsersController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::DashboardController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::TransfersController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Dashboard::WorksController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Dashboard::CollectionsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Dashboard::CollectionMembersController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Dashboard::NestCollectionsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Dashboard::ProfilesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::My::WorksController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::My::CollectionsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::My::HighlightsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::My::SharesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::PermissionTemplatesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::PermissionTemplateAccessesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::StatsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::FeaturesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::WorkflowsController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::WorkflowRolesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::AppearancesController.class_eval { include Hyrax::DashboardAuthorization }
  Hyrax::Admin::CollectionTypeParticipantsController.class_eval { include Hyrax::DashboardAuthorization }
end