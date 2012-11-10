source 'http://rubygems.org'

gem 'rails', '3.2.6'

gem 'mysql2'
gem 'devise'
gem "bcrypt-ruby", :require => "bcrypt"
gem "devise-encryptable"

gem 'haml'
gem 'has_scope'
gem "psych", "~> 1.3.3"


gem 'anjlab-bootstrap-rails', :require => 'bootstrap-rails',
                              :git => 'git://github.com/anjlab/bootstrap-rails.git'

group :assets do
  gem "sass-rails", "~> 3.2.5"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier", ">= 1.0.3"
  gem "therubyracer"
end

gem 'jquery-rails'

group :development do
  gem "capistrano", :require => false
  gem 'capistrano-recipes', :require => false
  gem 'capistrano_colors', :require => false
  gem "erb2haml"
  gem "rails_best_practices"
  gem "pry-rails"
  gem "thin"
end

group :development, :test do
  gem 'rspec-rails',        '~> 2.11.0'
  gem 'factory_girl_rails', '~> 3.5.0'
  gem 'guard-rspec',        '~> 1.2.0'
end

group :test do
  gem "faker", "~> 1.0.1"
  gem "launchy"
  gem 'spork',              '>= 0.9.0.rc9'
  gem 'guard-spork',        '~> 1.1.0'
  gem 'guard-bundler',      '~> 1.0.0'
  gem "capybara",           "~> 1.1.2"
  gem "database_cleaner"
  gem "shoulda"
  gem "email_spec"
  gem "simplecov", require: false

  gem 'rb-fsevent', '>= 0.4.3', :require => false
  gem 'growl',      '~> 1.0.3', :require => false
  gem 'rb-inotify', '>= 0.8.6', :require => false
  gem 'libnotify',  '~> 0.5.7', :require => false
end

group :production do
  gem "exception_notification"
end
