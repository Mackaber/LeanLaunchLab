# encoding: utf-8
require 'highline'

Capistrano::Configuration.instance.load do |instance|  

  require File.expand_path("#{File.dirname(__FILE__)}/util")
  require File.expand_path("#{File.dirname(__FILE__)}/database")
  
  instance.set :local_rails_env, ENV['RAILS_ENV'] || 'development' unless exists?(:local_rails_env)
  instance.set :stage, 'production' unless exists?(:stage)
  instance.set :db_local_clean, false unless exists?(:db_local_clean)
  
  namespace :db do
    namespace :local do
      desc 'Synchronize your local database using remote database data'
      task :sync, :roles => :db do
        if Util.prompt 'Are you sure you want to erase your local database with server database'
          local_db  = Database::Local.new(instance)
          remote_db = Database::Remote.new(instance)

          Database.check(local_db, remote_db)
          
          remote_db.dump.download
          local_db.load(remote_db.output_file, instance.fetch(:db_local_clean))
        end
      end
    end
  end
end