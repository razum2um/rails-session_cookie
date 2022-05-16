# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rspec'
gem 'rspec-rails'
gem 'rspec-benchmark', '~> 0.3'
gem 'rspec-github', '~> 2.3'

gem 'rubocop', '~> 1.29'
gem 'rubocop-rake', '~> 0.6'
gem 'rubocop-rspec', '~> 2.10'
gem 'rubocop-performance', '~> 1.13'

gem 'simplecov', '~> 0.21'
gem 'codecov', require: false

# test devise with memory database
gem 'devise', '~> 4.8.1' if ENV.fetch('BUNDLE_GEMFILE', nil) =~ /warden/
gem 'sqlite3', '~> 1.4'

# benchmarking test
gem 'capybara', '~> 2.15', require: false
gem 'benchmark-ips', '~> 2.7', require: false

# dev
gem 'rake'
gem 'appraisal', '~> 2.4', require: false

# be sure to generate gemfiles like
# CI=1 bundle exec appraisal generate
gem 'pry-byebug' unless ENV['CI']

# Specify your gem's dependencies in rails-session_cookie.gemspec
gemspec
