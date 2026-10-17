# frozen_string_literal: true

require_relative "lib/zat/version"

Gem::Specification.new do |spec|
  spec.name = "zat"
  spec.version = Zat::VERSION
  spec.authors = ["Amalrik Maia"]
  spec.email = ["amalrik.maia@gmail.com"]

  spec.summary = "Render Markdown in the terminal, in pure Ruby."
  spec.description = <<~DESC
    Zat renders Markdown in the terminal with colors, tables, syntax highlighting
    and inline images, like mdcat. It is pure Ruby with zero runtime dependencies,
    and doubles as a lab for measuring ZJIT and Ractors on Ruby 4.1.
  DESC
  spec.homepage = "https://github.com/amalrik/zat"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.1.0.preview1"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "exe/*", "LICENSE", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["zat"]
  spec.require_paths = ["lib"]

  # Zero runtime dependencies, by design: the whole pipeline must run inside
  # Ractors, and common gems (kramdown, Rouge, unicode-display_width) don't.
  # test/zat/gemspec_test.rb enforces this.
end
