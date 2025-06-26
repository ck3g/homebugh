
# Set your full path to application.
deploy_to = "/home/deploy/apps/homebugh"
app_path = "#{deploy_to}/current"
shared_path = "#{deploy_to}/shared"

# Set unicorn options
worker_processes 2
preload_app true
timeout 120
listen "#{shared_path}/sockets/unicorn.sock", :backlog => 2048

# Spawn unicorn master worker for user apps (group: apps)
# user 'deploy', 'deploy'

# Fill path to your app
working_directory app_path

# Should be 'production' by default, otherwise use other env
rails_env = ENV['RAILS_ENV'] || 'production'

# Log everything to one file
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

# Set master PID location
pid "#{app_path}/tmp/pids/unicorn.pid"

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
