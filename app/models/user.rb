# frozen_string_literal: true

# sets basic behaviors for a user
class User < ApplicationRecord
  include Hydra::User
  include Hydra::RoleManagement::UserRoles
  include Hyrax::User
  include Hyrax::UserUsageStats
  include Blacklight::User

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?

  # DISABLE RUBOCOP BECAUSE DEVISE REQUIRES A PARTICULAR FORMAT
  # rubocop:disable Style/SymbolArray
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable, :recoverable, :confirmable,
         :omniauthable, omniauth_providers: [:cas, :saml]
  # rubocop:enable Style/SymbolArray

  # T/F whether user has at least one role
  def role?(role)
    !(roles.map(&:name) & Array(role)).empty?
  end

  # OVERRIDE FROM HYRAX: to map osu and uo roles to group & visibility
  # https://github.com/samvera/hydra-head/blob/v10.6.2/hydra-access-controls/lib/hydra/user.rb
  def groups
    groups = super
    groups << 'osu' unless (groups & %w[osu_affiliate osu_user]).empty?
    groups << 'uo' unless (groups & %w[uo_affiliate uo_user]).empty?
    groups
  end
  # END OVERRIDE

  # method needed for messaging
  def mailboxer_email(_obj = nil)
    email
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.from_omniauth(access_token)
    email = email_from_omniauth(access_token)
    role = role_from_omniauth(access_token.provider.to_s)
    user = User.where(email: email).first_or_create do |user|
      user.email = email
      user.roles << role unless role.nil?
    end
    user.skip_confirmation!
    user.skip_confirmation_notification!
    user.save
    user
  end

  def self.email_from_omniauth(access_token)
    case access_token.provider.to_s
    when 'cas' then access_token.extra.osuprimarymail.to_s
    when 'saml' then "#{access_token.uid}@uoregon.edu"
    else access_token.uid
    end
  end

  def self.role_from_omniauth(provider)
    case provider
    when 'cas' then Role.find_by_name('osu_user')
    when 'saml' then Role.find_by_name('uo_user')
    end
  end
end
