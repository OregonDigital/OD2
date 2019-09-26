# frozen_string_literal:true

# Sets the abilities of the user and authorizes actions
class Ability
  include Hydra::Ability
  include Hyrax::Ability
  include OregonDigital::Ability::WorkCreateAbility
  include OregonDigital::Ability::WorkEditAbility
  include OregonDigital::Ability::WorkDeleteAbility

  def custom_permissions
    can(%i[show add_user remove_user index edit update destroy], Role)

    # Apply works edit permissions
    work_edit_ability
    work_create_ability
    work_delete_ability
  end

  def work_classes
    [SolrDocument, ActiveFedora::Base]
  end

  def admin_permission_roles
    %w[admin collection_curator]
  end

  def manager_permission_roles
    admin_permission_roles << 'depositor'
  end
end
