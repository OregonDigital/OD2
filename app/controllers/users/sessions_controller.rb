# frozen_string_literal: true

require 'mail'

# This class processes users who are trying to login.
# It redirects if it receives an university email
class Users::SessionsController < Devise::SessionsController
  before_action :redirect_if_university, only: [:create]

  protected

  def redirect_if_university
    domain = Mail::Address.new(params[:user][:email]).domain
    split_domain = domain.to_s.split('.').last(2).first 
    translated_domain = translate_domain(split_domain)
    case translated_domain
    when 'uoregon' then redirect_to new_uo_session_path
    when 'oregonstate' then redirect_to new_osu_session_path
    end
  end

  def translate_domain(domain)
    translated_domain = ''
    if domain == 'oregonstate' || domain == 'orst'
      translated_domain = 'oregonstate'  
    elsif domain == 'uoregon'
      translated_domain == 'uoregon'
    end
    translated_domain
  end
end
