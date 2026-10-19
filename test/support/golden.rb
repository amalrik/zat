# frozen_string_literal: true

# Byte-for-byte comparison of rendered fixtures against test/fixtures/<name>.<columns>.ansi.
# ZAT_UPDATE_GOLDEN=1 rewrites the expected files instead.
module Golden
  DIR = File.expand_path("../fixtures", __dir__)

  def self.names = Dir["#{DIR}/*.md"].map { File.basename(it, ".md") }.sort

  def self.terminal(columns) = Zat::Terminal::Capabilities.new(tty: true, columns:, color_depth: :truecolor)

  def self.render(name, columns: 80) = Zat.render(File.read("#{DIR}/#{name}.md"), terminal: terminal(columns))

  def assert_golden(name, columns: 80)
    actual = Golden.render(name, columns:)
    path = "#{DIR}/#{name}.#{columns}.ansi"
    File.write(path, actual) if ENV["ZAT_UPDATE_GOLDEN"]

    assert File.exist?(path), "missing #{path}: run ZAT_UPDATE_GOLDEN=1 rake test"
    assert_equal readable(File.read(path)), readable(actual)
  end

  private

  # Escapes spelled out so a failing diff shows which style changed.
  def readable(ansi) = ansi.gsub("\e", "\\e")
end
