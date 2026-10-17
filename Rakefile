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
    $LOAD_PATH.unshift File.expand_path("lib", __dir__)
    require "zat/markdown"
    require_relative "test/markdown/support/spec_suite"
  end

  desc "Rewrite test/markdown/spec/passing.txt with every spec example that passes"
  task update: :load do
    puts "#{SpecSuite.update!} of #{SpecSuite.examples.size} spec examples pass"
  end

  desc "Spec examples passing, per section"
  task report: :load do
    rows = SpecSuite.report
    width = rows.map { it[1].size }.max
    rows.each { |spec, section, pass, total| puts format("%-10s %-*s %3d/%-3d", spec, width, section, pass, total) }
    pass, total = rows.sum { it[2] }, rows.sum { it[3] }
    puts format("%-10s %-*s %3d/%-3d (%.1f%%)", "total", width, "", pass, total, 100.0 * pass / total)
  end
end

task default: %i[standard test]
