# frozen_string_literal:true

# These events are triggered by actions with OregonDigital Actors
Hyrax.config.callback.set(:after_oembed_error) do |user, errors|
  OregonDigital::OembedErrorService.new(user, errors).call
end

Hyrax.config.callback.set(:ld_fetch_success) do |user, uri|
  OregonDigital::LdFetchSuccessService.new(user, uri).call
end

Hyrax.config.callback.set(:ld_fetch_error) do |user, uri|
  OregonDigital::LdFetchErrorService.new(user, uri).call
end

Hyrax.config.callback.set(:ld_fetch_exhaust) do |user, uri|
  OregonDigital::LdFetchExhaustService.new(user, uri).call
end
