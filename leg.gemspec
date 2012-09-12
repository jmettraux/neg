
Gem::Specification.new do |s|

  s.name = 'leg'

  s.version = File.read(
    File.expand_path('../lib/leg/version.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'https://github.com/jmettraux/leg'
  s.rubyforge_project = 'ruote'
  s.summary = 'a leg larser'

  s.description = %{
jumping on one leg, a leg larser
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Rakefile',
    'lib/**/*.rb', 'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 2.9.0'

  s.require_path = 'lib'
end

