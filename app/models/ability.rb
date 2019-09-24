# frozen_string_literal:true

# Sets the abilities of the user and authorizes actions
class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += %i[everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end

    can(%i[create show add_user remove_user index edit update destroy], Role) if current_user.admin?

    # Apply works edit permissions
    cannot(%i[edit update], all_work_types)
    can(%i[edit update], all_work_types) if current_user.role?(edit_any_work_permissions)
    can(%i[edit update], all_work_types, depositor: current_user.email) if current_user.role?(edit_my_work_permissions)
  end

  def all_work_types
    [SolrDocument, FileSet] + Hyrax.config.curation_concerns
  end

  private

  def edit_any_work_permissions
    %w[admin collection_curator]
  end

  def edit_my_work_permissions
    %w[admin collection_curator depositor]
  end
end
