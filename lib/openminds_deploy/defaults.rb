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
end
