# frozen_string_literal:true

require 'oembed'

OEmbed::Providers.register_all

## Register OSU Mediaspace Provider
osu_ms_provider = OEmbed::Provider.new('https://media.oregonstate.edu/oembed')
osu_ms_provider << 'https://media.oregonstate.edu/id*'
osu_ms_provider << 'https://media.oregonstate.edu/media/id*'
osu_ms_provider << 'https://media.oregonstate.edu/media/t*'
OEmbed::Providers.register(osu_ms_provider)

# Register OSU Mediaspace test site Provider
osu_ms_test_provider = OEmbed::Provider.new('https://1650751.mediaspace.kaltura.com/oembed')
osu_ms_test_provider << 'https://1650751.mediaspace.kaltura.com/id*'
OEmbed::Providers.register(osu_ms_test_provider)
