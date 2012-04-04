begin
  require 'bundler/capistrano'
rescue LoadError
  $stderr.puts <<-INSTALL
The openminds_deploy/rails3 recipe requires bundler's deploy task. For this to work we need the bundler gem (>=1.0.0):
  gem install bundler
INSTALL
end

configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do
  namespace :openminds do
    task :check_rails3_compat do
      if roles[:app].servers.any? {|server| %w(zuurstof.openminds.be kobalt.openminds.be koper.openminds.be zink.openminds.be).include?(server.host) }
      abort "This server is not Rails 3 compatible. Mail support@openminds.be to move your account to a compatible server."
      end
    end
  end

  before "deploy:update_code", "openminds:check_rails3_compat"
  before "deploy:setup", "openminds:check_rails3_compat"
end
