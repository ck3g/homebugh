source 'http://rubygems.org'

gem 'rails', '3.2.6'

gem 'mysql2'
gem 'devise'
gem 'haml'

gem "bcrypt-ruby", :require => "bcrypt"


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
end

group :development, :test do
  gem "launchy"
end

group :test do
  gem 'rspec-rails',        '~> 2.7.0'
  gem 'factory_girl_rails', '~> 3.5.0'
  gem 'spork',              '>= 0.9.0.rc9'
  gem 'guard-spork',        '~> 0.3.1'
  gem 'guard-rspec',        '~> 0.5.0'
  gem 'guard-bundler',      '~> 0.1.3'
  gem "capybara",           "~> 1.1.1"
  gem "database_cleaner"

  gem 'rb-fsevent', '>= 0.4.3', :require => false
  gem 'growl',      '~> 1.0.3', :require => false
  gem 'rb-inotify', '>= 0.8.6', :require => false
  gem 'libnotify',  '~> 0.5.7', :require => false
end
