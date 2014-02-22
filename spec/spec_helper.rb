require 'simplecov'
SimpleCov.start 'rails'

require 'rubygems'
#uncomment the following line to use spork with the debugger

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/shared_behaviors/**/*.rb")].each {|f| require f}

I18n.locale = :en

RSpec.configure do |config|
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include Devise::TestHelpers, type: :controller
  config.extend LoginMacros, type: :controller

  config.include RequestMacros, type: :request

  # Include Factory Girl syntax to simplify calls to factories
  config.include FactoryGirl::Syntax::Methods
  config.include RequestLoginMacros
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
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

end
