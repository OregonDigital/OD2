# frozen_string_literal: true
require 'mail'

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :redirect_if_university, only: [:create]

  protected

    def redirect_if_university
      Rails.logger.info(Mail::Address.new(params[:user][:email]).domain.to_s)
      case Mail::Address.new(params[:user][:email]).domain.to_s
      when 'uoregon.edu' then redirect_to new_uo_session_path 
      when 'oregonstate.edu' then redirect_to new_osu_session_path
      else
        # Do nothing
      end
    end
end
