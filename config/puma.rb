rails_env = ENV.fetch("RAILS_ENV") { "development" }
environment rails_env

if rails_env == "production"
  directory '/home/deploy/apps/homebugh/current'

  # Puma process and state files
  pidfile '/home/deploy/apps/homebugh/shared/tmp/pids/puma.pid'
  state_path '/home/deploy/apps/homebugh/shared/tmp/pids/puma.state'

  # Control app socket for pumactl
  activate_control_app "unix:///home/deploy/apps/homebugh/shared/tmp/sockets/pumactl.sock"

  # Where to bind Puma
  bind 'unix:///home/deploy/apps/homebugh/shared/tmp/sockets/puma.sock'

  # Logs
  stdout_redirect '/home/deploy/apps/homebugh/shared/log/puma.stdout.log',
                  '/home/deploy/apps/homebugh/shared/log/puma.stderr.log', true
else
  # Development defaults
  pidfile 'tmp/pids/puma.pid'
  state_path 'tmp/pids/puma.state'
  bind 'tcp://127.0.0.1:3000'
end

# Threads and workers
threads 0, 5
workers 2
preload_app!

# ActiveRecord support
plugin :tmp_restart
