require 'simplecov'
SimpleCov.start 'rails'

require 'rubygems'
#uncomment the following line to use spork with the debugger

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'devise'
require 'rspec/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/shared_behaviors/**/*.rb")].each {|f| require f}

I18n.locale = :en

RSpec.configure do |config|
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.extend LoginMacros, type: :controller
  config.include Features::AuthMacros, type: :feature
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!

  config.before(:all) do
    I18n.locale = :en
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)

    # Force loading of Devise mappings early
    # Rails.application.reload_routes!
    Devise.mappings.keys.each { |key| Devise.mappings[key] }
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction

    Rails.application.routes.default_url_options[:host] = 'localhost'
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, type: :controller) do
    @request.env["devise.mapping"] = Devise.mappings[:user] if @request
  end

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
