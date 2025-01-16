source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# TODO: make this a version specification once we get a new release cut
# gem 'hydra-derivatives', git: 'https://github.com/samvera/hydra-derivatives.git'

gem "blacklight_range_limit", "~> 7.0"
gem 'browse-everything'
# coffee-rails is a requirement for Hyrax or one of its dependencies but hasn't
# been added to either gemspecs
gem 'coffee-rails', '~> 4.2'
gem 'cookieconsent'
gem 'dalli', '~> 3.2.3'
gem 'devise'
gem "edtf", "~> 3.0"
gem 'hydra-role-management'
gem 'hyrax', '~> 4.0'
# gem 'hyrax-migrator', github: 'OregonDigital/hyrax-migrator', branch: 'master'
gem 'jquery-rails'
gem 'sassc-rails'
gem 'chosen-rails'
gem 'pg'
gem 'puma'
gem 'rails', '~> 6.0.6'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sidekiq', '~> 7.0'
gem 'streamio-ffmpeg'
gem 'stemmify'
gem 'tzinfo-data'
gem 'uglifier', '>= 1.3.0'
gem 'ruby-oembed'
gem 'bootstrap', '~> 4.0'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'blacklight_advanced_search'
gem 'blacklight-oembed'
gem 'blacklight_dynamic_sitemap'
gem 'triplestore-adapter', git: 'https://github.com/osulp/triplestore-adapter'
gem 'faraday_middleware'
gem 'blacklight_iiif_search', '~> 2.0'
gem 'rubyzip', '~> 2'
gem 'zip_tricks', '~> 5.3'
gem 'bulkrax', github: 'samvera/bulkrax', ref: '62517e67876d96c7a0bedb288370a4f10eb0b4c4' #v8.2.0
# gem 'willow_sword', github: 'notch8/willow_sword', branch: 'main'
gem 'jquery-datatables-rails'

# Security Audit updates
gem 'loofah', '>= 2.2.3'

# Login gems
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'omniauth-cas'
gem 'omniauth-saml'

# Honeycomb
gem 'honeycomb-beeline', '>= 2.10.0'
gem 'libhoney', '>= 2.1.0'

# Yabeda
gem 'yabeda'
gem 'yabeda-prometheus'
gem 'yabeda-sidekiq'
gem 'yabeda-rails'
gem 'yabeda-puma-plugin'
gem 'yabeda-http_requests'

# Recaptcha
gem "recaptcha", require: "recaptcha/rails"
gem 'blacklight_oai_provider'

group :development do
  # listen is a requirement of puma but isn't part of its gemspec
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'axe-matchers'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.17'
  gem 'factory_bot_rails'
  gem 'poltergeist'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'selenium-webdriver', '~> 3'
  gem 'webmock'
end

group :test do
  gem 'coveralls', '~> 0.8'
  gem 'database_cleaner', '~> 1.8'
  gem 'equivalent-xml'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec-activemodel-mocks'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers', '~> 4'
  gem 'simplecov', '>= 0.9'
end

gem "vcr", "~> 5.1"

# INSTALL: Get the new Font Awesome
gem 'font-awesome-sass', '~> 6.4', '>= 6.4.2'
