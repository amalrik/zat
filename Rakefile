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

namespace :spec do
  task :load do
    require_relative "lib/zat/markdown"
    require_relative "test/markdown/support/spec_suite"
  end

  desc "Rewrite test/markdown/spec/passing.txt with every spec example that passes"
  task update: :load do
    puts "#{SpecSuite.update!} of #{SpecSuite.examples.size} spec examples pass"
  end

  desc "Spec examples passing, per section"
  task report: :load do
    rows = SpecSuite.report
    width = rows.map { it.section.size }.max
    rows.each { puts format("%-10s %-*s %3d/%-3d", it.spec, width, it.section, it.passed, it.total) }
    passed, total = rows.sum(&:passed), rows.sum(&:total)
    puts format("%-10s %-*s %3d/%-3d (%.1f%%)", "total", width, "", passed, total, 100.0 * passed / total)
  end
end

task default: %i[standard test]
