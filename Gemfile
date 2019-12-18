source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# TODO: make this a version specification once we get a new release cut
gem 'hydra-derivatives', git: 'https://github.com/samvera/hydra-derivatives.git'

gem 'lograge'
gem 'browse-everything'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'hydra-role-management', '~> 1.0.2'
gem 'hyrax', github: 'samvera/hyrax', tag: 'v2.6.0'
gem 'hyrax-migrator', github: 'OregonDigital/hyrax-migrator', branch: 'master'
gem 'jquery-rails'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.1.6'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'tzinfo-data'
gem 'uglifier', '>= 1.3.0'
gem 'ruby-oembed'
gem 'blacklight-oembed'
gem 'triplestore-adapter', git: 'https://github.com/osulp/triplestore-adapter'
gem 'faraday_middleware', '~> 0.10.0'
gem 'haml'

# Security Audit updates
gem 'loofah', '>= 2.2.3'
gem 'rubyzip', '>= 1.2.2'

# Login gems
gem 'omniauth-rails_csrf_protection', '~> 0.1'
gem 'omniauth-cas'
gem 'omniauth-saml'

# Honeycomb
gem 'honeycomb-beeline', '>= 1.0.0'
gem 'rack-honeycomb', '~> 0.5.0'

# Recaptcha
gem "recaptcha", require: "recaptcha/rails"

group :development do
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
  gem 'selenium-webdriver'
  gem 'webmock'
end

group :test do
  gem 'coveralls', '~> 0.8'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec-activemodel-mocks'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers', '~> 4'
  gem 'simplecov', '>= 0.9'
end
