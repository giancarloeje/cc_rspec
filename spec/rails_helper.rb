# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Add additional requires below this line. Rails is not loaded until this point!
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara/selenium/driver'
require 'capybara/poltergeist/driver'
require 'rack/test'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
 Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Capybara Settings for Selenium Web Driver
Selenium::WebDriver::Chrome::Service.driver_path = "#{Rails.root}/spec/web_drivers/chromedriver.exe"
Capybara.register_driver :selenium do |app|
  desired_capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
          args: %w[--disable-web-security --start-maximized --incognito]
      }
  )
  Capybara::Selenium::Driver.new app, browser: :chrome, desired_capabilities: desired_capabilities
end
Capybara.javascript_driver = :selenium

#Capybara.register_driver :poltergeist do |app|
#  Capybara::Poltergeist::Driver.new(app, {js_errors: true, window_size: [1024, 768], timeout: 500})
#end
#
#Capybara.register_driver :poltergeist_debug do |app|
#  Capybara::Poltergeist::Driver.new(app, :inspector => true)
#end
#
#Capybara.register_driver :poltergeist_debug do |app|
#  Capybara::Poltergeist::Driver.new(app, :inspector => true)
#end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  #config.include Warden::Test::Helpers

  config.before do
    Capybara.current_driver = :selenium
    Capybara.javascript_driver = :selenium
    Capybara.run_server = true
    Capybara.default_max_wait_time = 30
    Capybara.server_port = 9876
    Capybara.app_host = "http://127.0.0.1:#{Capybara.server_port}"
    #Capybara.ignore_hidden_elements = false
  end

  config.include Capybara::DSL
  config.include FactoryBot::Syntax::Methods
  config.include Features::SessionHelpers, type: :feature
  config.include Requests::APIHelpers, type: :request
  config.include Warden::Test::Helpers
  config.include Mongoid::Matchers, type: :model
  config.include(MailerMacros)
  config.before(:each) { reset_email }

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  Devise.setup do |config|
    config.lock_strategy = :failed_attempts
    config.unlock_strategy = :email
    config.maximum_attempts = 3
    config.stretches = 1
  end

  PDFKit.configure do |config|
    config.wkhtmltopdf = "/home/giancarloeje/.rvm/gems/jruby-9.2.7.0@global/bin/wkhtmltopdf"
  end

end
