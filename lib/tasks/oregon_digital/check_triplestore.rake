# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Run triplestore healthcheck and post on slack if fail'
  task ts_healthcheck: :environment do
    include OregonDigital::TriplestoreHealth
    uri = uris[gen_random]
    return if OregonDigital::TriplestoreHealth.triplestore_is_alive?(uri)

    post_message
  end
end

def post_message
  url = OD2::Application.config.slack_ts_hook
  params = { 'text' => 'Warning: triplestore is DOWN' }
  conn = Faraday.new(
    url: url,
    headers: { 'Content-Type' => 'application/json' }
  )
  conn.post do |request|
    request.body = params.to_json
  end
end

def gen_random
  prng = Random.new
  prng.rand(100)
end

# rubocop:disable Metrics/MethodLength
def uris
  ['http://opaquenamespace.org/ns/people/AndersonMarySiuslaw',
   'http://opaquenamespace.org/ns/people/AndersonMaurice',
   'http://opaquenamespace.org/ns/people/AndersonMax',
   'http://opaquenamespace.org/ns/people/AndersonNorman',
   'http://opaquenamespace.org/ns/people/AndersonRichard',
   'http://opaquenamespace.org/ns/people/AndersonRobertS',
   'http://opaquenamespace.org/ns/people/AndersonRobertaFrasier',
   'http://opaquenamespace.org/ns/people/AndersonRoberta',
   'http://opaquenamespace.org/ns/people/AndersonRon',
   'http://opaquenamespace.org/ns/people/AndersonRonnie',
   'http://opaquenamespace.org/ns/people/AndersonShae',
   'http://opaquenamespace.org/ns/people/AndersonSilas',
   'http://opaquenamespace.org/ns/people/AndersonStanford',
   'http://opaquenamespace.org/ns/people/AndersonSteve',
   'http://opaquenamespace.org/ns/people/AndersonTannerJ',
   'http://opaquenamespace.org/ns/people/AndersonTed',
   'http://opaquenamespace.org/ns/people/AndersonThyrzaI',
   'http://opaquenamespace.org/ns/people/AndersonTylerJ',
   'http://opaquenamespace.org/ns/people/AndersonVickie',
   'http://opaquenamespace.org/ns/people/AndersonWinifredM',
   'http://opaquenamespace.org/ns/people/AndertonTylerJ',
   'http://opaquenamespace.org/ns/people/AndingKevinA',
   'http://opaquenamespace.org/ns/people/AndoMichiYasui',
   'http://opaquenamespace.org/ns/people/AndranovichAlex',
   'http://opaquenamespace.org/ns/people/AndreevAndrei',
   'http://opaquenamespace.org/ns/people/AndrewsBarbara',
   'http://opaquenamespace.org/ns/people/AndrewsBruceX2',
   'http://opaquenamespace.org/ns/people/AndrewsErmin',
   'http://opaquenamespace.org/ns/people/AndrewsFred',
   'http://opaquenamespace.org/ns/people/AndrewsGeorge',
   'http://opaquenamespace.org/ns/people/AndrewsLeroyBrown',
   'http://opaquenamespace.org/ns/people/AndrewsMarthaJ',
   'http://opaquenamespace.org/ns/people/AndrewsWarrenC',
   'http://opaquenamespace.org/ns/people/AndrieuKennethD',
   'http://opaquenamespace.org/ns/people/AndrosDeeG',
   'http://opaquenamespace.org/ns/people/AndrosDee19242003',
   'http://opaquenamespace.org/ns/people/AnetCliff',
   'http://opaquenamespace.org/ns/people/AnetRobert',
   'http://opaquenamespace.org/ns/people/AngelBrandon',
   'http://opaquenamespace.org/ns/people/AngellHomerD',
   'http://opaquenamespace.org/ns/people/AngelusPhotoCoPortlandOR',
   'http://opaquenamespace.org/ns/people/AngermayerChristopherM',
   'http://opaquenamespace.org/ns/people/AngierJake',
   'http://opaquenamespace.org/ns/people/AngiuliNicoleF',
   'http://opaquenamespace.org/ns/people/AngsteadPaul',
   'http://opaquenamespace.org/ns/people/AnkenyDollieAnnaMiller',
   'http://opaquenamespace.org/ns/people/AnonsenTraci',
   'http://opaquenamespace.org/ns/people/AnthonyAW',
   'http://opaquenamespace.org/ns/people/AnthonyJames',
   'http://opaquenamespace.org/ns/people/AntifacistCommitteeSovietYouth',
   'http://opaquenamespace.org/ns/people/AnunsenFred',
   'http://opaquenamespace.org/ns/people/AnunsenZellaSoults',
   'http://opaquenamespace.org/ns/people/AnunsonFred',
   'http://opaquenamespace.org/ns/people/AokiS',
   'http://opaquenamespace.org/ns/people/ApeluKaulanaE',
   'http://opaquenamespace.org/ns/people/AppersonJT',
   'http://opaquenamespace.org/ns/people/ApplegateMorayL',
   'http://opaquenamespace.org/ns/people/ArabianVictoria',
   'http://opaquenamespace.org/ns/people/ArbuckleDick',
   'http://opaquenamespace.org/ns/people/ArchambeauLauretta',
   'http://opaquenamespace.org/ns/people/ArcherLillianLillyH',
   'http://opaquenamespace.org/ns/people/ArcherLillianH',
   'http://opaquenamespace.org/ns/people/ArcherSam',
   'http://opaquenamespace.org/ns/people/ArchulettaCarlos',
   'http://opaquenamespace.org/ns/people/ArcuriGiuliaM',
   'http://opaquenamespace.org/ns/people/ArendsJane',
   'http://opaquenamespace.org/ns/people/ArescoAnthony',
   'http://opaquenamespace.org/ns/people/ArimitsuJiro',
   'http://opaquenamespace.org/ns/people/AristyEdwin',
   'http://opaquenamespace.org/ns/people/ArmitageJamesHerbert',
   'http://opaquenamespace.org/ns/people/ArmitageStellaV',
   'http://opaquenamespace.org/ns/people/ArmsteadArikK',
   'http://opaquenamespace.org/ns/people/ArmstrongBeauN',
   'http://opaquenamespace.org/ns/people/ArmstrongDale',
   'http://opaquenamespace.org/ns/people/ArmstrongDavidJ',
   'http://opaquenamespace.org/ns/people/ArmstrongDerek',
   'http://opaquenamespace.org/ns/people/ArmstrongIke',
   'http://opaquenamespace.org/ns/people/ArmstrongJulie',
   'http://opaquenamespace.org/ns/people/ArmstrongKarringtonX',
   'http://opaquenamespace.org/ns/people/ArmstrongKatherine',
   'http://opaquenamespace.org/ns/people/ArmstrongRexE',
   'http://opaquenamespace.org/ns/people/ArmstrongShelbyL',
   'http://opaquenamespace.org/ns/people/ArndtEmil',
   'http://opaquenamespace.org/ns/people/ArnoldBenjaminL',
   'http://opaquenamespace.org/ns/people/ArnoldBruceC',
   'http://opaquenamespace.org/ns/people/ArnoldFrank',
   'http://opaquenamespace.org/ns/people/ArnoldJohn',
   'http://opaquenamespace.org/ns/people/ArnoldLeFrancis',
   'http://opaquenamespace.org/ns/people/ArnoldSteve',
   'http://opaquenamespace.org/ns/people/ArozAnson',
   'http://opaquenamespace.org/ns/people/ArpSandra',
   'http://opaquenamespace.org/ns/people/ArrendondoJaime',
   'http://opaquenamespace.org/ns/people/ArringtonGuy',
   'http://opaquenamespace.org/ns/people/ArroyoAlex',
   'http://opaquenamespace.org/ns/people/ArtPearl',
   'http://opaquenamespace.org/ns/people/ArtauLouisP',
   'http://opaquenamespace.org/ns/people/ArthurGerald',
   'http://opaquenamespace.org/ns/people/ArtisDominicJ',
   'http://opaquenamespace.org/ns/people/ArtztEdwinL',
   'http://opaquenamespace.org/ns/people/AschbacherAlexandraM']
end
# rubocop:enable Metrics/MethodLength
