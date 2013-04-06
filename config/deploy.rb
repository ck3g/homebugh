set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :application, "homebugh"
set :repository,  "git@github.com:ck3g/homebugh.git"
set :branch, "master"
set :shared_host, "194.165.39.126"
set :domain, shared_host
set :unicorn_env, "production"
set :rails_env, "production"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "kalastiuz"

set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :export

set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# set :rake, "#{rake} --trace"

after "deploy", "deploy:cleanup" # keep only the last 5 releases
after "deploy:update_code", "deploy:migrate"
after "deploy:finalize_update", "deploy:symlink_config"

CONFIG_FILES = %w(database mail)
namespace :deploy do
  task :setup_config, :roles => :app do
    run "mkdir -p #{shared_path}/config"
    CONFIG_FILES.each do |file|
      put File.read("config/#{file}.yml.example"), "#{shared_path}/config/#{file}.yml"
    end
    puts "Now edit the config files in #{shared_path}"
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/mail.yml #{release_path}/config/mail.yml"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "Tail production log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    trap ("INT") { puts "\nInterrupded"; exit 0; }
    puts
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

require 'capistrano_colors'
require 'bundler/capistrano'
require "capistrano-unicorn"
