source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'hydra-role-management'
gem 'hyrax', github: 'samvera/hyrax', tag: 'v2.4.0'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'pg'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.6'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
gem 'tzinfo-data'
gem 'uglifier', '>= 1.3.0'
gem 'net-http-persistent', '~> 2.9'
gem 'triplestore-adapter', git: 'https://github.com/osulp/triplestore-adapter'

# Security Audit updates
gem 'loofah', '>= 2.2.3'
gem 'rubyzip', '>= 1.2.2'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.17'
  gem 'debase'
  gem 'debase-ruby_core_source'
  gem 'factory_bot_rails'
  gem 'fcrepo_wrapper'
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'ruby-debug-ide'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
  gem 'webmock'
end

group :test do
  gem 'coveralls', '~> 0.8'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'
  gem 'simplecov', '>= 0.9'
end
