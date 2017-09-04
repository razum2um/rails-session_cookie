require 'bundler/setup'

# rubocop:disable Lint/HandleExceptions
begin
  require 'pry-byebug'
rescue LoadError
end
# rubocop:enable Lint/HandleExceptions

DIR = File.dirname(File.expand_path(__FILE__))
Dir["#{DIR}/../spec/support/**/*.rb"].each { |f| require f }

require 'rspec/rails'
require 'rails/session_cookie'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run_excluding performance: true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

## common

def dumped_session(session = {})
  JSON(session.map { |k, v| [k.to_s, v] } .sort)
end
