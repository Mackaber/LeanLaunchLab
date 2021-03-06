role :web, ENV["DEPLOY_STAGING_WEB"]  # Your HTTP server, Apache/etc
role :app, ENV["DEPLOY_STAGING_WEB"]  # This may be the same as your `Web` server
role :db,  ENV["DEPLOY_STAGING_DB"], :primary => true  # This is where Rails migrations will run

set :port, ENV["DEPLOY_STAGING_PORT"]

set :deploy_to, "/home/#{user}/apps/#{application}/#{stage}"
set :current_path, "#{deploy_to}/current"
set :rails_env, stage
set :environment, stage

set :unicorn_pid, "/tmp/unicorn.pid"
set :unicorn_socket, "/tmp/unicorn.sock"

set :branch, ENV["DEPLOY_STAGING_BRANCH"]
