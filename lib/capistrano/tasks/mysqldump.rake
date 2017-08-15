namespace :mysqldump do
  task :default do
    on roles(:db) do
      dump
      import
    end
  end

  def setup_variables
    @mysqldump_config = fetch :mysqldump_config, YAML.load_file("config/database.yml")[fetch(:rails_env).to_s]
    unless @mysqldump_config
      raise "Cannot load database config for #{fetch(:rails_env)} environment"
    end

    host = @mysqldump_config["host"]

    # overwrite these if necessary
    @mysqldump_bin = fetch :mysqldump_bin, "`which mysqldump`"
    mysqldump_remote_tmp_dir = fetch :mysqldump_remote_tmp_dir, "/tmp"
    mysqldump_local_tmp_dir = fetch :mysqldump_local_tmp_dir, "/tmp"
    @mysqldump_location = fetch :mysqldump_location, host && !host.empty? && host != "localhost" ? :remote : :local
    @mysqldump_options = fetch :mysqldump_options, {}

    # for convenience
    mysqldump_filename = "%s-%s.sql" % [fetch(:application), Time.now.to_i]
    mysqldump_filename_gz = "%s.gz" % mysqldump_filename
    @mysqldump_remote_filename = File.join( mysqldump_remote_tmp_dir, mysqldump_filename_gz )
    @mysqldump_local_filename = File.join( mysqldump_local_tmp_dir, mysqldump_filename )
    @mysqldump_local_filename_gz = File.join( mysqldump_local_tmp_dir, mysqldump_filename_gz )

    @mysqldump_ignore_tables = fetch :mysqldump_ignore_tables, []
    @mysqldump_tables = fetch :mysqldump_tables, []
  end

  def default_options
    setup_variables
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

      options.merge! mysqldump_credential_options(username, password)
    end
  end

  task :dump do
    options = default_options
    options.merge! @mysqldump_options
    password, database = @mysqldump_config.values_at *%w( password database )
    mysqldump_cmd = "#{@mysqldump_bin} #{mysqldump_options_string(options)} #{database} #{[@mysqldump_tables].flatten.compact.join ' '}"

    case @mysqldump_location
    when :remote
      # TODO: use `set` instead of binding to local variables
      remote_filename = @mysqldump_remote_filename
      local_filename_gz = @mysqldump_local_filename_gz
      mysqldump_cmd += " | gzip > %s" % @mysqldump_remote_filename

      on roles(:db) do
        execute(
          mysqldump_cmd,
          interaction_handler: {
            /^Enter password:/ => "#{password}\n"
          })

        download! remote_filename, local_filename_gz
        execute "rm #{remote_filename}"
      end
      `gunzip #{@mysqldump_local_filename_gz}`
    when :local
      mysqldump_cmd += " > %s" % @mysqldump_local_filename

      `#{mysqldump_cmd}`
    end
  end

  task :import do
    config = YAML.load_file("config/database.yml")["development"]
    username, password, database = config.values_at *%w( username password database )

    credentials_string = mysqldump_options_string mysqldump_credential_options(username, password)

    mysql_cmd = "mysql #{credentials_string}"
    `#{mysql_cmd} -e "drop database #{database}; create database #{database}"`
    `#{mysql_cmd} #{database} < #{@mysqldump_local_filename}`
    `rm #{@mysqldump_local_filename}`
  end
end
