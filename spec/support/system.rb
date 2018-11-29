# frozen_string_literal:true

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.after(:each, type: :system) do
    driven_by :rack_test
    Capybara.reset_sessions!
    page.driver.reset!
    DatabaseCleaner.clean!
  end

  config.before(:each, type: :system, js: true) do
    if ENV['SELENIUM_DRIVER_URL'].present?
      driven_by :selenium, using: :chrome,
                           options: {
                             browser: :remote,
                             url: ENV.fetch('SELENIUM_DRIVER_URL'),
                             desired_capabilities: :chrome
                           }
      Capybara.run_server = false
      Capybara.app_host = ENV.fetch('CAPYBARA_APP_HOST')
      Capybara.ignore_hidden_elements = false
      Capybara.javascript_driver = :selenium
    else
      Capybara.register_driver :headless_chrome do |app|
        options = Selenium::WebDriver::Chrome::Options.new
        %w[headless window-size=1280x1280 disable-gpu].each { |arg| options.add_argument(arg) }
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end

      driven_by :headless_chrome
    end
  end

  config.before(:all, type: :system) do
    # Assets take a long time to compile. This causes two problems:
    # 1) the profile will show the first feature test taking much longer than it
    #    normally would.
    # 2) The first feature test will trigger rack-timeout
    #
    # Precompile the assets to prevent these issues.
    visit '/assets/application.css'
    visit '/assets/application.js'
  end
end
