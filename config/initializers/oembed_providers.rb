# frozen_string_literal:true

require 'oembed'

OEmbed::Providers.register_all

## Register OSU Mediaspace Provider
osu_ms_provider = OEmbed::Provider.new('https://media.oregonstate.edu/oembed')
osu_ms_provider << 'https://media.oregonstate.edu/id*'
osu_ms_provider << 'https://media.oregonstate.edu/media/id*'
osu_ms_provider << 'https://media.oregonstate.edu/media/t*'
OEmbed::Providers.register(osu_ms_provider)
