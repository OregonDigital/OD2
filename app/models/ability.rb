# frozen_string_literal:true

# Sets the abilities of the user and authorizes actions
class Ability
  include Hydra::Ability
  include Hyrax::Ability
  include OregonDigital::Ability::WorkCreateAbility
  include OregonDigital::Ability::WorkEditAbility
  include OregonDigital::Ability::WorkDeleteAbility
  include OregonDigital::Ability::WorkShowAbility
  include OregonDigital::Ability::WorkReviewAbility
  include OregonDigital::Ability::CollectionAbility

  def custom_permissions
    can(%i[show add_user remove_user index edit update destroy], Role)

    # Apply works edit permissions
    work_edit_ability
    work_create_ability
    work_delete_ability
    work_show_ability
    work_review_ability
    collection_ability
  end

  def work_classes
    [SolrDocument, ActiveFedora::Base]
  end

  def in_depositors_collection?(edit_access_person)
    edit_access_person.include?(current_user.email)
  end

  def admin_permission_roles
    %w[admin collection_curator]
  end

  def manager_permission_roles
    admin_permission_roles << 'depositor'
  end

  def community_roles
    %w[community_affiliate]
  end

  def osu_roles
    %w[osu_affiliate osu_user community_affiliate]
  end

  def uo_roles
    %w[uo_affiliate uo_user community_affiliate]
  end
end
