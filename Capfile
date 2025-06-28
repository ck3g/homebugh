# Capfile

# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load Capistrano plugins
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/puma"
require "capistrano/whenever"

# Load custom tasks from `lib/capistrano/tasks` if you have any
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }