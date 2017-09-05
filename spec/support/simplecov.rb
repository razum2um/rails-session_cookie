require 'simplecov'
require 'codeclimate-test-reporter'

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

if ENV['BUNDLE_GEMFILE'] =~ /warden/ # only compute coverage with all capacity
  SimpleCov.start 'rails' do
    add_filter 'lib/rails/session_cookie/version.rb'
  end
end
