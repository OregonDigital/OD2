source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# TODO: make this a version specification once we get a new release cut
# gem 'hydra-derivatives', git: 'https://github.com/samvera/hydra-derivatives.git'

gem "blacklight_range_limit", "~> 6"
gem 'browse-everything'
# coffee-rails is a requirement for Hyrax or one of its dependencies but hasn't
# been added to either gemspecs
gem 'coffee-rails', '~> 4.2'
gem 'cookieconsent'
gem 'dalli', '~> 3.2.3'
gem 'devise'
gem "edtf", "~> 3.0"
gem 'hydra-role-management'
gem 'hyrax', '3.6.0'
gem 'hyrax-migrator', github: 'OregonDigital/hyrax-migrator', branch: 'master'
gem 'jquery-rails'
gem 'sassc-rails'
gem 'chosen-rails'
gem 'pg'
gem 'puma', '~> 5.6'
gem 'rails', '~> 5.2'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq', '~> 6.4'
gem 'streamio-ffmpeg'
gem 'stemmify'
gem 'tzinfo-data'
gem 'uglifier', '>= 1.3.0'
gem 'ruby-oembed'
gem 'blacklight_advanced_search', '~> 6.4'
gem 'blacklight-oembed'
gem 'blacklight_dynamic_sitemap'
gem 'triplestore-adapter', git: 'https://github.com/osulp/triplestore-adapter'
gem 'faraday_middleware', '~> 0.10.0'
gem 'blacklight_iiif_search', '~> 1.0'
gem 'rubyzip', '~> 2'
gem 'zip_tricks', '~> 5.3'
gem 'bulkrax', github: 'samvera/bulkrax', ref: 'dfed1bb796af4b864898cefcb5fedb939e2cb44d' #v9.0.2
#gem 'willow_sword', '~> 0.1.0', github: 'notch8/willow_sword'

# Security Audit updates
gem 'loofah', '>= 2.2.3'

# Login gems
gem 'omniauth-rails_csrf_protection', '~> 0.1'
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
  gem 'rubocop', '~> 0.93'
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
