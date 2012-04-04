configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do
  set :use_sudo, false
  set :group_writable, false # Shared environment
  set :keep_releases, 3
  set :deploy_via, :remote_cache

  default_run_options[:pty] = true

  set(:deploy_to) {"/home/#{user}/apps/#{application}"}

  ssh_options[:forward_agent] = true

  # database.yml: we never keep it in our repository
  namespace :dbconfig do
    desc 'Create database.yml in shared/config'
    task :copy_database_config do
      run "mkdir -p #{shared_path}/config"
      put File.read('config/database.yml'), "#{shared_path}/config/database.yml"
    end

    desc 'Link in the production database.yml'
    task :link do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
  after 'deploy:finalize_update', 'dbconfig:link'
  after 'deploy:setup', 'dbconfig:copy_database_config'

  after :deploy, 'deploy:cleanup'

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

  desc 'Tail application log'
  task :tail_log, :roles => :app do
    run "tail -f #{shared_path}/log/#{rails_env}.log"
  end
end
