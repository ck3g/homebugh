# Capfile

# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load Git SCM plugin
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Load Capistrano plugins
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/rbenv"
require "capistrano/puma"

require "whenever/capistrano"
