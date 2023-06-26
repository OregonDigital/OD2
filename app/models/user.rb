# frozen_string_literal: true

# sets basic behaviors for a user
class User < ApplicationRecord
  include Hydra::User
  include Hydra::RoleManagement::UserRoles
  include Hyrax::User
  include Hyrax::UserUsageStats
  include Blacklight::User

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?
  before_create :role_from_devise

  # DISABLE RUBOCOP BECAUSE DEVISE REQUIRES A PARTICULAR FORMAT
  # rubocop:disable Style/SymbolArray
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable, :recoverable, :confirmable,
         :omniauthable, :validatable, omniauth_providers: [:cas, :saml]
  # rubocop:enable Style/SymbolArray

  # Instead of deleting users, we'll set the deactivated flag
  def destroy
    update_attributes(deactivated: true) unless deactivated
  end

  # Prevent login if the user is deactivated
  def active_for_authentication?
    super && !deactivated
  end

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
    groups << 'restricted' if role?(Ability.manager_permission_roles)
    groups << 'private' if role?(Ability.admin_permission_roles)
    groups
  end
  # END OVERRIDE

  # method needed for messaging
  def mailboxer_email(_obj = nil)
    email
  end

  # Override from devise to make a determination of whether to send email notification or not
  def send_confirmation_notification?
    super && !email.include?('uoregon') && !email.include?('oregonstate')
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
    User.where(email: email).first_or_create do |u|
      u.email = email
      u.roles << role unless role.nil?
      u.skip_confirmation!
    end
  end

  def self.email_from_omniauth(access_token)
    case access_token.provider.to_s
    when 'cas' then access_token.extra.eduPersonPrincipalName.to_s
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

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    service = OregonDigital::UserAttributeService.new(self)
    !service.institutional_user? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  private

  def role_from_devise
    com_user_role = Role.find_by_name('community_user')
    roles << com_user_role if roles.blank? && !com_user_role.nil?
  end
end
