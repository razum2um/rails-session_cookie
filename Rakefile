require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'codeclimate-test-reporter'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

# Same as bin/codeclimate-test-reporter, but don't complain if no coverage found
task :coverage do
  exit unless ENV['CI']

  repo_token = ENV['CODECLIMATE_REPO_TOKEN']
  if repo_token.nil? || repo_token.empty?
    STDERR.puts 'Cannot post results: environment variable CODECLIMATE_REPO_TOKEN must be set.'
    exit
  end

  COVERAGE_FILE = ARGV.first || 'coverage/.resultset.json'
  unless File.exist?(COVERAGE_FILE)
    STDERR.puts 'Coverage results not found'
    exit
  end

  begin
    results = JSON.parse(File.read(COVERAGE_FILE))
  rescue JSON::ParserError => e
    abort "Error encountered while parsing #{COVERAGE_FILE}: #{e}"
  end

  CodeClimate::TestReporter.run(results)
end

task default: %i[rubocop spec coverage]
