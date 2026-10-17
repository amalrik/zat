# frozen_string_literal: true

# Creates the labels, milestones and issues described in docs/PLANNING.md
# on the GitHub repository of the current directory, using the `gh` CLI.
#
#   ruby script/bootstrap_github.rb           # dry run: prints the commands
#   ruby script/bootstrap_github.rb --apply   # runs them

require "tempfile"

APPLY = ARGV.include?("--apply")
ISSUES_DIR = File.expand_path("../docs/issues", __dir__)

LABELS = {
  "milestone:setup" => "0E8A16", "milestone:mvp" => "0E8A16",
  "milestone:advanced" => "0E8A16", "milestone:protocols" => "0E8A16",
  "area:cli" => "1D76DB", "area:parser" => "1D76DB", "area:renderer" => "1D76DB",
  "area:terminal" => "1D76DB", "area:text" => "1D76DB", "area:tables" => "1D76DB",
  "area:syntax" => "1D76DB", "area:images" => "1D76DB",
  "area:infra" => "5319E7", "area:tests" => "5319E7", "area:performance" => "5319E7",
  "experiment:zjit" => "D93F0B", "experiment:ractor" => "E99695",
  "zjit:hot-path" => "FBCA04", "ractor-safety" => "F9D0C4", "gem:markdown" => "BFDADC",
  "type:feature" => "C5DEF5", "type:chore" => "C5DEF5", "type:research" => "C5DEF5",
  "blocked" => "B60205"
}.freeze

Issue = Data.define(:file, :title, :labels, :milestone, :body)

def run(*cmd)
  puts "$ #{cmd.map { |a| a.match?(/\s/) ? a.inspect : a }.join(" ")}"
  return unless APPLY

  system(*cmd) or warn("  failed (continuing)")
end

def meta(text, key) = text[/<!-- #{key}: (.+?) -->/, 1] or abort("missing #{key}")

issues = Dir[File.join(ISSUES_DIR, "Z-*.md")].sort.map do |file|
  text = File.read(file)
  Issue.new(
    file:,
    title: meta(text, "title"),
    labels: meta(text, "labels").split(",").map(&:strip),
    milestone: meta(text, "milestone"),
    body: text.gsub(/\A(?:<!-- .+? -->\n)+/, "")
  )
end

unknown = issues.flat_map(&:labels).uniq - LABELS.keys
abort "Labels without a color: #{unknown.join(", ")}" if unknown.any?

puts APPLY ? "== Applying ==" : "== Dry run (pass --apply to execute) =="

LABELS.each { |name, color| run("gh", "label", "create", name, "--color", color, "--force") }

issues.map(&:milestone).uniq.each do |title|
  run("gh", "api", "repos/{owner}/{repo}/milestones", "-f", "title=#{title}")
end

issues.each do |issue|
  Tempfile.create(["zat-issue", ".md"]) do |body|
    body.write(issue.body)
    body.flush
    run("gh", "issue", "create",
        "--title", issue.title,
        "--body-file", body.path,
        "--milestone", issue.milestone,
        *issue.labels.flat_map { |l| ["--label", l] })
  end
end
