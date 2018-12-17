# These events are triggered by actions with OregonDigital Actors
Hyrax.config.callback.set(:after_oembed_error) do |user, errors|
  OregonDigital::OembedErrorService.new(user, errors).call
end
