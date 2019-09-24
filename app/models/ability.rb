# frozen_string_literal:true

# Sets the abilities of the user and authorizes actions
class Ability
  include Hydra::Ability
  include Hyrax::Ability

  include OregonDigital::Ability::WorkEditAbility

  def custom_permissions
    can(%i[show add_user remove_user index edit update destroy], Role) if current_user.admin?

    # Apply works edit permissions
    work_edit_ability
  end

  def work_classes
    [SolrDocument, ActiveFedora::Base]
    # TODO: THIS WILL BE REMOVED ONCE WE NAIL DOWN THE ROLES AND PERMISSIONS MORE
    can(%i[show add_user remove_user index edit update destroy], Role) if current_user.admin?
    create_permissions.each do |perm|
      can(:create, ActiveFedora::Base) if current_user.roles.map(&:name).include?(perm)
    end
  end

  def create_permissions
    %w[admin collection_curator depositor]
  end
end
