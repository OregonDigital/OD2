# frozen_string_literal:true

# Sets the abilities of the user and authorizes actions
class Ability
  include Hydra::Ability

  include Hyrax::Ability

  include OregonDigital::Ability::WorkEditAbility

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
    work_edit_ability
  end

  def work_classes
    [SolrDocument, ActiveFedora::Base]
  end
end
