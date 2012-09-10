
$:.unshift('.') # 1.9.2

require 'rubygems'

require 'rake'
require 'rake/clean'


#
# clean

CLEAN.include('pkg')


#
# test / spec

task :spec do

  exec 'bundle exec rspec'
end

task :default => [ :spec ]
task :test => [ :spec ]


#
# gem

GEMSPEC_FILE = Dir['*.gemspec'].first
GEMSPEC = eval(File.read(GEMSPEC_FILE))
GEMSPEC.validate


desc %{
  builds the gem and places it in pkg/
}
task :build do

  sh "gem build #{GEMSPEC_FILE}"
  sh "mkdir pkg" rescue nil
  sh "mv #{GEMSPEC.name}-#{GEMSPEC.version}.gem pkg/"
end

desc %{
  builds the gem and pushes it to rubygems.org
}
task :push => :build do

  sh "gem push pkg/#{GEMSPEC.name}-#{GEMSPEC.version}.gem"
end

