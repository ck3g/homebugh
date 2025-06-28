# config/deploy/production.rb
server '198.211.96.190', user: 'deploy', roles: %w{web app db}
set :rails_env, :production