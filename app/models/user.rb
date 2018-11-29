# frozen_string_literal: true

class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  include Blacklight::User
  # Include default devise modules. Others available are:
  # devise :database_authenticatable, :registerable
  devise :omniauthable, omniauth_providers: [:cas]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.from_omniauth(access_token)
    User.where(provider: access_token.provider, uid: access_token.uid).first_or_create do |user|
      user.email = "#{access_token.uid}@oregonstate.edu"
    end
  end
end
