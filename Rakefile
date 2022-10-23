# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  puts "Tests:"
  puts FileList["test/**/test_*.rb"]
end

task default: :test

namespace :doc do
  task default: %i[rustdoc yard]

  desc "Generate Yard documentation"
  task :yard do
    run("bundle exec yard")
  end

  desc "Generate Rust documentation as JSON"
  task :rustdoc do
    run("cargo +nightly rustdoc -p ext -- -Zunstable-options --output-format json --document-private-items")
  end

  def run(cmd)
    system(cmd)
    fail if $? != 0
  end
end

task doc: "doc:default"
