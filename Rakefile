# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ["test/**/*_test.rb"]
end

namespace :test do
  # The Markdown parser alone, without the rest of Zat loaded.
  Minitest::TestTask.create(:markdown) do |t|
    t.test_prelude = 'require "zat/markdown"'
    t.test_globs = ["test/markdown/**/*_test.rb"]
  end
end

task default: :test
