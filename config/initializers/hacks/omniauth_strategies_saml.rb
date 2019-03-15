# frozen_string_literal:true

OmniAuth::Strategies::SAML.class_eval do
  def callback_url
    # Remove query_string to keep omniauth-saml from append query_string to SAML metadata
    full_host + script_name + callback_path
  end
end
