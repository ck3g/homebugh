source 'https://rubygems.org'

gem 'rails', '4.0.3'

gem "json", "~> 1.7.7"

gem 'mysql2', "~> 0.3.11"
gem 'devise', "~> 3.2.3"
gem "devise-encryptable", "~> 0.1.1"
gem 'haml-rails'
gem 'has_scope', "~> 0.5.1"
gem "psych", "~> 1.3.4"
gem 'anjlab-bootstrap-rails', "2.3.1.2", require: 'bootstrap-rails'
gem "simple_form", "~> 3.0.1"
gem "kaminari", "~> 0.14.1"
gem "meta-tags", "~> 1.3.0", require: "meta_tags"
gem "newrelic_rpm"
gem 'best_in_place', github: 'bernat/best_in_place', branch: 'rails-4'
gem 'chart-js-rails', '~> 0.0.4'
gem "select2-rails", '~> 3.5.1'

gem "sass-rails", "~> 4.0.1"
gem "coffee-rails", "~> 4.0.1"
gem "uglifier", ">= 1.3.0"
gem "therubyracer"
gem 'quiet_assets', '~> 1.0.2'

gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-deprecated_finders'

gem 'jquery-rails'
gem 'jquery-ui-rails'

group :development do
  gem "capistrano", require: false
  gem 'capistrano-recipes', require: false
  gem 'capistrano_colors', require: false
  gem 'capistrano-unicorn', '~> 0.1.10', require: false
  gem 'capistrano-rbenv', :require => false
  gem "erb2haml"
  gem "rails_best_practices"
  gem "thin"
  gem 'spring'
  gem "spring-commands-rspec"
end

group :development, :test do
  gem 'rspec-rails', '2.14.1'
  gem 'factory_girl_rails', '~> 3.5.0'
  gem "pry-rails"
end

group :test do
  gem "faker", "~> 1.0.1"
  gem "launchy"
  gem "capybara", "~> 2.2.1"
  gem "database_cleaner"
  gem "shoulda"
  gem "email_spec"
  gem "simplecov", require: false

  gem 'rb-fsevent', '>= 0.4.3', require: false
  gem 'growl',      '~> 1.0.3', require: false
  gem 'rb-inotify', '>= 0.8.6', require: false
  gem 'libnotify',  '~> 0.5.7', require: false
end

group :production do
  gem "exception_notification"
  gem 'unicorn'
end

