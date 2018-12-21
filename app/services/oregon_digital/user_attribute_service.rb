module OregonDigital
  class UserAttributeService

    def initialize(user_params)
      @domain = Mail::Address.new(user_params[:email]).to_s
      @parsed_domain = @domain.split('.')[-2]
      @rails_paths = Rails.application.routes.url_helpers 
    end

    def email_redirect_path
      domain_hash[@parsed_domain]
    end

    private

    def domain_hash
      { 
        oregonstate: "#{@rails_paths.new_osu_session_path}",
        orst: "#{@rails_paths.new_osu_session_path}",
        uoregon: "#{@rails_paths.new_uo_session_path}"
      }.with_indifferent_access
    end
  end
end