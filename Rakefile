# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec_github) do |t|
  t.rspec_opts = '--format RSpec::Github::Formatter -f documentation'
end

task ci: %i[rubocop spec_github]
task default: %i[rubocop spec]
