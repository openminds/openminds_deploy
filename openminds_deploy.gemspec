# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'openminds_deploy/version'

Gem::Specification.new do |s|
  s.name = 'openminds_deploy'
  s.version = OpenmindsDeploy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ['Jan De Poorter', 'Joren De Groof', 'Jeroen Jacobs']
  s.email = 'devel@openminds.be'
  s.homepage = 'http://openminds.be'
  s.summary = 'Common capistrano recipes for Openminds applications'
  s.description = 'The most commonly used tasks in Capistrano recipes'

  s.files = Dir['lib/**/*', 'README.rdoc']
  s.require_paths = ['lib']

  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency 'capistrano'
end
