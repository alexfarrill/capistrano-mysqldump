require 'capistrano'

module Capistrano
  module Mysqldump 

    # converts a hash of options into a string.
    # drops falsey-valued keys.
    # 
    # `{u: 'foo', 'single-transaction' => true, ignore-tables' => 'bar',  p: nil}`
    # => '-ufoo --ignore-tables=bar --single-transaction
    # 
    def self.options_string(options = nil)
      options
      options.map do |k,v|
        next unless v
        used_value = v == true ? nil : v
        used_prefix, used_join = if k.length == 1
          ["-", '']
        else
          ["--", '=']
        end

        "#{used_prefix}#{[k, used_value].compact.join used_join}"
      end.compact.join ' '
    end

    # returns credential options for a given username and password
    # when given an empty or nil password, does not include p: in the returned hash
    def self.credential_options(username, password)
      {}.tap do |opts|
        opts[:u] = username
        opts[:p] = password if password == true || password && !password.empty?
      end
    end

    def self.load_into(configuration)
      configuration.load do 
        namespace :mysqldump do
          task :default, :roles => :db do
            dump
            import
          end

          task :setup do
            @mysqldump_config = fetch :mysqldump_config, YAML.load_file("config/database.yml")[rails_env.to_s]
            unless @mysqldump_config
              raise "Cannot load database config for #{rails_env} environment"
            end

            host = @mysqldump_config["host"]

            # overwrite these if necessary
            @mysqldump_bin = fetch :mysqldump_bin, "`which mysqldump`"
            mysqldump_remote_tmp_dir = fetch :mysqldump_remote_tmp_dir, "/tmp"
            mysqldump_local_tmp_dir = fetch :mysqldump_local_tmp_dir, "/tmp"
            @mysqldump_location = fetch :mysqldump_location, host && !host.empty? && host != "localhost" ? :remote : :local
            @mysqldump_options = fetch :mysqldump_options, {}

            # for convenience
            mysqldump_filename = "%s-%s.sql" % [application, Time.now.to_i]
            mysqldump_filename_gz = "%s.gz" % mysqldump_filename
            @mysqldump_remote_filename = File.join( mysqldump_remote_tmp_dir, mysqldump_filename_gz )
            @mysqldump_local_filename = File.join( mysqldump_local_tmp_dir, mysqldump_filename )
            @mysqldump_local_filename_gz = File.join( mysqldump_local_tmp_dir, mysqldump_filename_gz )

            @mysqldump_ignore_tables = fetch :mysqldump_ignore_tables, []
            @mysqldump_tables = fetch :mysqldump_tables, []
          end

          def default_options
            setup
            username, password, host = @mysqldump_config.values_at *%w( username password host )
            {
              :h => host,
              :quick => true,
              "single-transaction" => true,
            }.tap do |options|

              password = true if @mysqldump_location == :remote

              if @mysqldump_ignore_tables.any?
                options['ignore-tables'] = [@mysqldump_ignore_tables].flatten.join ' '
              end

              options.merge! Mysqldump.credential_options(username, password)
            end
          end



          task :dump, :roles => :db do
            options = default_options
            options.merge! @mysqldump_options
            password, database = @mysqldump_config.values_at *%w( password database )
            mysqldump_cmd = "#{@mysqldump_bin} #{Mysqldump.options_string(options)} #{database} #{[@mysqldump_tables].flatten.compact.join ' '}"

            case @mysqldump_location
            when :remote
              mysqldump_cmd += " | gzip > %s" % @mysqldump_remote_filename

              run mysqldump_cmd do |ch, stream, out|
                ch.send_data "#{password}\n" if out =~ /^Enter password:/
              end

              download @mysqldump_remote_filename, @mysqldump_local_filename_gz, :via => :scp
              run "rm #{@mysqldump_remote_filename}"

              `gunzip #{@mysqldump_local_filename_gz}`
            when :local
              mysqldump_cmd += " > %s" % @mysqldump_local_filename

              `#{mysqldump_cmd}`
            end
          end

          task :import do
            config = YAML.load_file("config/database.yml")["development"]
            username, password, database = config.values_at *%w( username password database )

            credentials_string = Mysqldump.options_string Mysqldump.credential_options(username, password)
            
            mysql_cmd = "mysql #{credentials_string}"
            `#{mysql_cmd} -e "drop database #{database}; create database #{database}"`
            `#{mysql_cmd} #{database} < #{@mysqldump_local_filename}`
            `rm #{@mysqldump_local_filename}`
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Mysqldump.load_into(Capistrano::Configuration.instance)
end