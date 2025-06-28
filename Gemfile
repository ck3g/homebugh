source 'https://rubygems.org/'

gem 'rails', '8.0.2'

gem 'bootsnap', require: false

gem "json", "~> 2.3.0"

gem 'mysql2', "0.5.6"
gem 'devise', "~> 4.9.3"
gem "devise-encryptable", "~> 0.2.0"
gem 'haml'
gem 'has_scope', "~> 0.5.1"
gem "psych", "~> 3.3.4"
gem "simple_form", "~> 5.3.0"
gem "kaminari", "~> 1.2.2"
gem "meta-tags", "~> 2.22.0", require: "meta_tags"
gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"
gem "select2-rails", '~> 3.5.11'
gem 'chartkick', '~> 3.4.0'
gem 'draper'
gem 'aasm'
gem 'cancancan'
gem 'rack-cors'

gem 'bootstrap-sass', '~> 3.4.1'
gem "uglifier", ">= 4.2.0"
gem "sassc-ruby"
gem 'font-awesome-rails'
gem 'ffi'

gem 'activemodel-serializers-xml'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-deprecated_finders'

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'ruby-progressbar'

gem 'whenever', '~> 1.0.0'
gem 'mailgun-ruby'

gem 'eventmachine', '~> 1.2.7', require: false

gem 'sprockets-rails', require: 'sprockets/railtie'



# To support new ruby versions
gem 'ostruct'
gem 'logger'
gem 'benchmark'
gem 'observer'
gem 'abbrev'

gem 'recaptcha'

gem "puma"

group :development do
  gem "capistrano", "~> 3.18.0", require: false
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-puma', '~> 0.2.3', require: false
  
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem "erb2haml"
  gem "rails_best_practices"
  
  gem 'spring'
  gem "spring-commands-rspec"
  gem 'ed25519', '~> 1.2', '>= 1.2.4'
  gem 'bcrypt_pbkdf', '~> 1.0', '>= 1.0.1'
end

group :development, :test do
  gem 'rspec-rails', '~> 8.0.1'
  gem 'factory_bot_rails', '~> 6.2.0'
  gem "pry-rails"
end

group :test do
  gem 'rspec-activemodel-mocks'
  gem 'rails-controller-testing'
  gem "faker", "~> 2.14.0"
  gem "launchy"
  gem "capybara"
  gem "database_cleaner"
  gem "shoulda-matchers", '~> 5.3.0'
  gem "email_spec"
  gem 'simplecov', require: false

  gem 'rb-fsevent', '>= 0.4.3', require: false
  gem 'rb-inotify', '~> 0.11.1', require: false
  gem 'growl',      '~> 1.0.3', require: false
  gem 'libnotify',  '~> 0.9.4', require: false
end

group :production do
  gem "exception_notification"
end


