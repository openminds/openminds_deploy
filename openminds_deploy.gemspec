# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name = 'openminds_deploy'
  s.version = '1.0.7'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Jan De Poorter', 'Joren De Groof', 'Jeroen Jacobs', 'Bernard Grymonpon']
  s.email = 'devel@openminds.be'
  s.homepage = 'http://www.openminds.be'
  s.summary = 'Common capistrano recipes for Openminds applications'
  s.description = 'The most commonly used tasks in Capistrano recipes'

  s.files = Dir['lib/**/*', 'README.md']
  s.require_paths = ['lib']

  s.extra_rdoc_files = ['README.md']
  s.rdoc_options = ['--charset=UTF-8']

  s.add_dependency 'capistrano', '~> 2.5'
end
