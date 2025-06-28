# config/deploy.rb
lock '~> 3.18'

set :application, 'homebugh'
set :repo_url, 'git@github.com:ck3g/homebugh.git'

set :deploy_to, '/home/deploy/apps/homebugh'
set :branch, 'master'
set :rails_env, 'production'

# rbenv configuration
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '3.4.3' # Your Ruby version

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/mail.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Puma configuration
set :puma_threads,    [0, 5]
set :puma_workers,    2
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log,  "#{shared_path}/log/puma_error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

# Whenever configuration
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :bundle_without, %w{development test}.join(' ')

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism for Puma
      invoke 'puma:restart'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :puma do
  desc 'Start Puma in background with nohup (Puma 6+ compatible)'
  task :start do
    on roles(:app), pty: true do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :nohup, "bash -c 'cd #{current_path} && bundle exec puma -C config/puma.rb' > #{shared_path}/log/puma.nohup.log 2>&1 &"
        end
      end
    end
  end
end
