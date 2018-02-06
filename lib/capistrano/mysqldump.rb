require 'capistrano'
require "capistrano/dsl/mysqldump"
require 'sshkit'
self.extend Capistrano::DSL::Mysqldump

SSHKit::Backend::Netssh.send(:include, Capistrano::DSL::Mysqldump)

load File.expand_path("../tasks/mysqldump.rake", __FILE__)
