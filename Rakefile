# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "standard/rake"

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ["test/**/*_test.rb"]
end

namespace :test do
  Minitest::TestTask.create(:markdown) do |t|
    t.test_globs = ["test/markdown/**/*_test.rb"]
  end
end

task default: %i[standard test]
