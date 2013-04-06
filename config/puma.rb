rails_env = ENV["RAILS_ENV"] || "development"

threads 4,4

deploy_to = "/home/kalastiuz/apps/homebugh"
app_path = "#{deploy_to}/current"
shared_path = "#{deploy_to}/shared"

bind "unix://#{shared_path}/sockets/puma.sock"
pidfile "#{app_path}/tmp/puma/pid"
state_path "#{app_path}/tmp/puma/state"

activate_control_app
