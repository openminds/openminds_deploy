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
        abort 'This server is not Rails 3 compatible. Mail support@openminds.be to move your account to a compatible server.'
      end
    end
  end

  before 'deploy:update_code', 'openminds:check_rails3_compat'
  before 'deploy:setup', 'openminds:check_rails3_compat'

  namespace :deploy do
    namespace :assets do
      task :precompile, :roles => :web, :except => {:no_release => true} do
        old_rev = capture("cd #{previous_release} && git log --pretty=format:'%H' -n 1 | cat").strip
        new_rev = capture("cd #{latest_release} && git log --pretty=format:'%H' -n 1 | cat").strip
        assets_changed = capture("cd #{latest_release} && git diff #{old_rev} #{new_rev} --name-only | cat").include?('asset')
        gemfile_changed = capture("cd #{latest_release} && git diff #{old_rev} #{new_rev} --name-only | cat").include?('Gemfile.lock')
        if assets_changed || (gemfile_changed && Capistrano::CLI.ui.ask("Gemfile changed. Enter 'yes' to precomple assets?") == 'yes')
          run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
        else
          logger.info 'Skipping asset precompilation because there were no asset changes.'
        end
      end
    end
  end

  desc 'Prompts if new migrations are available and runs them if you want to'
  namespace :deploy do
    task :needs_migrations, :roles => :db, :only => {:primary => true} do
      old_rev = capture("cd #{previous_release} && git log --pretty=format:'%H' -n 1 | cat").strip
      new_rev = capture("cd #{latest_release} && git log --pretty=format:'%H' -n 1 | cat").strip
      migrations_changed = capture("cd #{latest_release} && git diff #{old_rev} #{new_rev} --name-only | cat").include?('db/migrate')
      if migrations_changed && Capistrano::CLI.ui.ask("New migrations pending. Enter 'yes' to run db:migrate") == 'yes'
        migrate
      end
    end
  end

  after 'deploy:update_code', 'deploy:needs_migrations'
end
