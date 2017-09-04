require 'bundler/setup'

# thanks for example: https://github.com/rails/rails/issues/27145
require 'action_controller/railtie'

class DebugSessionApp < Rails::Application
  COOKIE_KEY = 'cookie_store_key'.freeze
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: COOKIE_KEY
  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger
  Rails.logger.level = 2

  routes.draw do
    resources :home, only: [:index]
  end
end

class HomeController < ActionController::Base
  def index
    data = session.to_hash.except('session_id')
    render plain: JSON(data.sort)
  end
end

##

require 'rspec/rails'
require 'codeclimate-test-reporter'
require 'simplecov'

# rubocop:disable Lint/HandleExceptions
begin
  require 'pry-byebug'
rescue LoadError
end
# rubocop:enable Lint/HandleExceptions

# SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
#   CodeClimate::TestReporter::Formatter
# )

class SingleCodeClimateFormatter < CodeClimate::TestReporter::Formatter
  def format(simplecov_result)

    # HM.. it's single one in simplecov-0.13

    # simplecov_results = results.map do |command_name, data|
    #   SimpleCov::Result.from_hash(command_name => data)
    # end
    # simplecov_result =
    #   if simplecov_results.size == 1
    #     simplecov_results.first
    #   else
    #     merge_results(simplecov_results)
    #   end

    payload = to_payload(simplecov_result)
    CodeClimate::TestReporter::PayloadValidator.validate(payload)

    payload
  end
end
SimpleCov.formatter = ENV['CI'] ? SingleCodeClimateFormatter : SimpleCov::Formatter::HTMLFormatter
SimpleCov.start 'rails' do
  add_filter 'lib/rails/session_cookie/version.rb'
end

##

require 'rails/session_cookie'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
