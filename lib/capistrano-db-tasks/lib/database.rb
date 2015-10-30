# encoding: utf-8
module Database
  class Base 
    attr_accessor :config
    def initialize(cap_instance)
      @cap = cap_instance
    end
    
    def mysql?
      @config['adapter'] =~ /^mysql/
    end
    
    def postgresql?
      @config['adapter'] == 'postgresql'
    end
    
    def credentials
      if mysql?
        " -u #{@config['username']} " + (@config['password'] ? " -p\"#{@config['password']}\" " : '')
      elsif postgresql?
        " -U #{@config['username']} " # FIXME how to provide password in pg_dump command line?
      end
    end
    
    def database
      @config['database']
    end
    
  private
    def dump_cmd
      if mysql?
        "mysqldump #{credentials} #{database}"
      elsif postgresql?
        "pg_dump #{credentials} -c -O #{database}"
      end
    end

    def import_cmd(file)
      if mysql?
        "mysql #{credentials} -D #{database} < #{file}"
      else
        "psql #{credentials} #{database} < #{file}"
      end
    end
  end

  class Remote < Base
    attr_accessor :output_file
    def initialize(cap_instance)
      super(cap_instance)
      @cap.run("cat #{@cap.current_path}/config/database.yml") { |c, s, d| @config = YAML.load(d)[@cap.rails_env.to_s] }
    end
          
    def output_file
      @output_file ||= "db/dump_#{database}.sql.bz2"
    end
    
    def dump
      @cap.run "cd #{@cap.current_path}; #{dump_cmd} | bzip2 - - > #{output_file}"
      self
    end
    
    def download(local_file = "#{output_file}") 
      remote_file = "#{@cap.current_path}/#{output_file}"
      
      server = @cap.find_servers(:roles => :db).first
      @cap.sessions[server].sftp.connect {|tsftp| tsftp.download!(remote_file, local_file) }
    end
  end

  class Local < Base
    def initialize(cap_instance)
      super(cap_instance)
      @config = YAML.load_file(File.join('config', 'database.yml'))[@cap.local_rails_env]
    end
    
    # cleanup = true removes the mysqldump file after loading, false leaves it in db/
    def load(file, cleanup)
      unzip_file = File.join(File.dirname(file), File.basename(file, '.bz2'))
      system("bunzip2 -f #{file} && rake db:drop db:create && #{import_cmd(unzip_file)} && rake db:migrate") 
      File.unlink(unzip_file) if cleanup
    end
  end
  
  def self.check(local_db, remote_db) 
    unless (local_db.mysql? && remote_db.mysql?) || (local_db.postgresql? && remote_db.postgresql?)
      raise 'Only mysql or postgresql on remote and local server is supported' 
    end
  end
end
