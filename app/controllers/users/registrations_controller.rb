# frozen_string_literal: true

require 'mail'

# This class handles registering users.
# When it receives an email from a university it redirects
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_university, only: [:create]

  protected

  def redirect_if_university
    domain = Mail::Address.new(params[:user][:email]).domain
    case domain.to_s.split('.').last(2).first
    when 'uoregon' then redirect_to new_uo_session_path
    when 'oregonstate' then redirect_to new_osu_session_path
    end
  end
end
