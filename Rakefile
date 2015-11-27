require "bundler/gem_tasks"
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--format documentation","--color"]
  t.pattern = FileList[ 'spec/*.rb' ] - [ 'spec_helper' ]
  t.verbose = true
end 

# running rspec test
desc "Run tests"
task :default => :spec
