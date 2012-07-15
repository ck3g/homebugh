require 'capistrano_colors'
require 'bundler/capistrano'

set :application, "homebugh"
set :repository,  "git@github.com:ck3g/homebugh.git"
set :branch, "rails3.2"
set :domain, "homebugh.info"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "kalastiuz"

set :deploy_to, "/home/kalastiuz/rails/#{application}"
set :deploy_via, :export

set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

after "deploy", "deploy:cleanup" # keep only the last 5 releases
after "deploy:update_code", "deploy:migrate"

namespace :deploy do
  task :after_symlink do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
