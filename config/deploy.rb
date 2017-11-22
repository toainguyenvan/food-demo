# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, "food-demo"
set :user, "ubuntu"
set :repo_url, "git@github.com:toainguyenvan/food-demo.git"
# set :pty, true
# set :linked_files, %w(config/database.yml config/application.yml)
# set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads)
# set :keep_releases, 5
# set :rvm_type, :user
# set :use_sudo,        false
# set :deploy_via,      :remote_cache
# set :ssh_options, { port: 22, keys: ['./config/pem/server.pem'] }
# set :puma_rackup, -> {File.join(current_path, "config.ru")}
# set :puma_state, -> {"#{shared_path}/tmp/pids/puma.state"}
# set :puma_pid, -> {"#{shared_path}/tmp/pids/puma.pid"}
# set :puma_bind, -> {"unix://#{shared_path}/tmp/sockets/puma.sock"}
# set :puma_conf, -> {"#{shared_path}/puma.rb"}
# set :puma_access_log, -> {"#{shared_path}/log/puma_access.log"}
# set :puma_error_log, -> {"#{shared_path}/log/puma_error.log"}
# set :puma_role, :app
# set :puma_env, fetch(:rack_env, fetch(:rails_env, "production"))
# set :puma_threads, [0, 8]
# set :puma_workers, 0
# set :puma_worker_timeout, nil
# set :puma_init_active_record, true
# set :puma_preload_app, false
# Don't change these unless you know what you're doing
set :rbenv_ruby,      '2.2.3'
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
