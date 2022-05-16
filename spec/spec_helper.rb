# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
SimpleCov.start

if ENV.fetch('CI', nil) && ENV.fetch('CODECOV_TOKEN', nil)
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/SuppressedException
end

begin
  require 'devise'
  require 'warden/config'
  DEVISE_APP = true
  WARDEN_CONFIG = Warden::Config.new
rescue LoadError
  DEVISE_APP = false
  WARDEN_CONFIG = nil
end

DIR = File.dirname(File.expand_path(__FILE__))
Dir["#{DIR}/../spec/support/**/*.rb"].sort.each { |f| require f }

require 'rspec/rails'
require 'rspec-benchmark'
require 'capybara'

require 'rails-session_cookie'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run_excluding performance: true unless DEVISE_APP

  config.filter_run_excluding warden: true unless DEVISE_APP

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

## common

def dumped_session(session = {})
  JSON(session.map { |k, v| [k.to_s, v] }.sort)
end
