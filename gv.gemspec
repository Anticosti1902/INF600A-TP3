# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','gv','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'gv'
  s.version = GestionEquipements::VERSION
  s.author = 'Alexandre Fernandes-Bartolomeu'
  s.email = 'el.portug@gmail.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Petit jeu permettant d\'equiper differentes armes et armures pour battre un goblin'
  s.files = `git ls-files`.split("
")

  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'gv'

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest', '~> 5')
  s.add_runtime_dependency('gli','2.12.0')
end
