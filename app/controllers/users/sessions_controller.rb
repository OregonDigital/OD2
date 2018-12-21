# frozen_string_literal: true

require 'mail'

# This class processes users who are trying to login.
# It redirects if it receives an university email
class Users::SessionsController < Devise::SessionsController
  before_action :redirect_if_university, only: [:create]

  protected

  def redirect_if_university
    domain = Mail::Address.new(params[:user][:email]).domain
    case domain.to_s.split('.').last(2).first
    when 'uoregon' then redirect_to new_uo_session_path
    when 'oregonstate' then redirect_to new_osu_session_path
    when 'orst' then redirect_to new_osu_session_path
    end
  end
end
