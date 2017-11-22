set :stage, :production
set :rails_env, :production
set :deploy_to, "app"
set :branch, :master
server "54.255.245.92", user: "ubuntu", roles: %w{web app db}