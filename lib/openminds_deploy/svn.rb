configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)

configuration.load do
  set :scm, :svn
  set :scm_password, Proc.new { CLI.password_prompt "SVN Password: "}
end