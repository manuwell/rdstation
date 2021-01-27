require_relative 'config/environment'
require "rake/testtask"
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    # nothing to load here
  end
end

desc 'Run all tests'
Rake::TestTask.new(:test) do |t|
  t.libs << "config"
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test
