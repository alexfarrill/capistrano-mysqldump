Capistrano::Configuration.instance.load do
  namespace :mysqldump do
    task :default, :roles => :db do
      # overwrite these if necessary
      set :mysqldump_bin, "/usr/local/mysql/bin/mysqldump" unless exists?(:mysqldump_bin)
      set :mysqldump_remote_tmp_dir, "/tmp" unless exists?(:mysqldump_remote_tmp_dir)
      set :mysqldump_local_tmp_dir, "/tmp" unless exists?(:mysqldump_local_tmp_dir)

      set :mysqldump_filename_gz, "%s-%s.sql.gz" % [application, Time.now.to_i]
      set :mysqldump_remote_filename, File.join( mysqldump_remote_tmp_dir, mysqldump_filename_gz )
      set :mysqldump_local_filename, File.join( mysqldump_local_tmp_dir, mysqldump_filename_gz )
      
      set :mysqldump_location, :remote

      dump
      import
    end

    task :dump, :roles => :db do
      config = YAML.load_file("config/database.yml")[rails_env.to_s]
      username, password, database, host = config.values_at *%w( username password database host )

      case mysqldump_location
      when :remote
        mysqldump_cmd = "%s -u %s -p %s | gzip > %s" % [mysqldump_bin, username, database, mysqldump_remote_filename]

        run mysqldump_cmd do |ch, stream, out|
          ch.send_data "#{password}\n" if out =~ /^Enter password:/
        end

        download mysqldump_remote_filename, mysqldump_local_filename, :via => :scp
        `gunzip #{mysqldump_local_filename}`
      when :local
        mysqldump_cmd = "%s -u %s" % [ mysqldump_bin, username ]
        mysqldump_cmd += " -p#{password}" if password && password.any?
        mysqldump_cmd += " -h #{host}" if host && host.any?
        mysqldump_cmd += " %s | gzip > %s" % [ database, mysqldump_local_filename]
        
        `#{mysqldump_cmd}`
      end
    end

    task :import do
      config = YAML.load_file("config/database.yml")["development"]
      username, password, database = config.values_at *%w( username password database )

      mysqldump_filename = mysqldump_local_filename.gsub(/\.gz$/, '')
      mysql_cmd = "mysql -u#{username}"
      mysql_cmd += " -p#{password}" if password && password.any?
      `#{mysql_cmd} -e "drop database #{database}; create database #{database}"`
      `#{mysql_cmd} #{database} < #{mysqldump_filename}`
      `rm #{mysqldump_filename}`
    end
  end
end