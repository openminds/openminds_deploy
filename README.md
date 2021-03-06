# Openminds Deploy Gem

This is a set of defaults for deploying to the Openminds shared hosting servers. These include our best practices for deployment, and should make a very clean Capfile.

## Installation
These deploy recipes are all available in the openminds_deploy gem, which can be installed via rubygems:

    gem install openminds_deploy

## Available recipes
* openminds_deploy/defaults   - Defaults for every deployment.
* openminds_deploy/git        - for deploying with git.
* openminds_deploy/svn        - for deploying with SVN.
* openminds_deploy/passenger  - for deploying to a passenger account (zink, pro-004, pro-005, pro-006, pro-007)
* openminds_deploy/lighttpd   - for deploying to a lighttpd account (zuurstof, kobalt, koper)
* openminds_deploy/rails3     - if you're deploying a Rails3 application. Takes care of Bundler

## Example recipe

In this recipe we just set-up our user & application-name, the repository (git in this case) where our application can be found, the server we are deploying to, and require the necessary deployment files.

The block around it is a convenience rescue if someone would deploy with this Capfile that doesn't have this gem installed. The require's can be edited like you need.

    load 'deploy' if respond_to?(:namespace) # cap2 differentiator

    set :user, 'account_name'
    set :application, 'my_application'

    set :repository, 'git@server.openminds.be:git/my_application.git'

    server 'server.openminds.be', :app, :web, :db, :primary => true

    begin
      require 'openminds_deploy/defaults'
      require 'openminds_deploy/git'
      require 'openminds_deploy/passenger'
      require 'openminds_deploy/rails3'
    rescue LoadError => e
      $stderr.puts <<INSTALL
    There was an exception while trying to deploy your application. Most likely you do not have the openminds_deploy gem installed.
    You can install the gem like this:
      gem install openminds_deploy
    INSTALL
      $stderr.puts "Exception thrown: #{e}"
      exit 1
    end

If you want to override some settings from the openminds_deploy recipes, define them after the openminds block.

    ...
    begin
      require 'openminds_deploy/defaults'
    rescue LoadError
      $stderr.puts "Install the openminds_deploy gem"
      exit 1
    end

    set :deploy_to, "/home/#{user}/apps/staging/#{application}"

### Rails 3.1 with asset pipeline

If you deploy a Rails 3.1 application with the default settings, you need to precompile the assets upon deployment. If you are using capistrano >= 2.8.0 you can add the following line to your Capifile:

    load 'deploy/assets'

If you are using an older version of capistrano, you should upgrade to a later version. If for some reason you can't do that, you can append these lines to your Capfile:

    before "deploy:symlink", "deploy:assets"

    namespace :deploy do
      desc "Compile assets"
      task :assets do
        run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
      end
    end

Also, the standard capistrano behavior will try to touch the
public/images, public/javascripts, public/stylesheets which will
cause warnings. Add this line to the Capfile or deploy.rb to
avoid that:

    set :normalize_asset_timestamps, false

## Recipes in detail
### openminds_deploy/defaults
* sets up variables like `use_sudo` and `group_writable`
* enables SSH forwarding
* adds a task to link config/database.yml
* automatically checks if new migrations are available and asks you if you want to run them if there are

### openminds_deploy/git
* sets up the SCM and enables git-submodules to be installed

### openminds_deploy/svn
* sets up the SCM for svn and adds a password-prompt (don't keep your password in your SCM!)

### openminds_deploy/passenger
* sets up all stop/start/restart tasks for Passenger

### openminds_deploy/lighttpd
* sets up all stop/start/restart tasks for Lighttpd

### openminds_deploy/rails3
* sets up bundling tasks with Bundler and does a basic check to see if the server you're on supports Rails 3.
* only precompiles assets if there are changes detected in your assets or Gemfile

### openminds_deploy/configs
* gives you some tasks to copy and symlink config files to the server

#### Example ####
To set up [Faye](http://faye.jcoglan.com/) you might have different configs for each environment (development, staging, production, ...). For doing so you might create the following config in `config/faye.yml`

    development:
      server_url: https://example.dev:9292/faye

    staging:
      server_url: https://staging.example.com:9292/faye

    production:
      server_url: https://example.com:9292/faye

Once you have that set up, you'll want to create the config during the first deploy and symlink the configs after each deploy. To set that up you'll have to set the `configs` variable in your `Capfile`:

    set :configs, %w[faye]

Don't forget to require `openminds_deploy/configs` **after** setting the variable. That's it, now your configs will be copied and symlinked automatically.
