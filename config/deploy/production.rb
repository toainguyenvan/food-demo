set :stage, :production
set :rails_env, :production
# set :deploy_to, "app"
set :branch, "master"

role :app,'ubuntu@54.255.245.92'
role :web,'ubuntu@54.255.245.92'
role :db,'ubuntu@54.255.245.92'

server "54.255.245.92", user: "ubuntu", roles: %w{web app db}