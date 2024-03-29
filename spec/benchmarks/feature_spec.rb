# frozen_string_literal: true

require 'benchmark/ips'
require 'spec_helper'

RSpec.feature 'Speed using capybara in feature test', performance: true do
  include RSpec::Benchmark::Matchers
  include Devise::Test::IntegrationHelpers if DEVISE_APP

  let!(:user) { User.create!(email: 'ad@ad.ad', password: '123123') }
  let!(:session_data) { User.serialize_into_session(user) }

  let(:key) { "feature:user:#{user.id}" }
  let(:user_id_arr) { session_data.first }
  let(:digest) { session_data.last }

  def session_cookie!(cache = true)
    # Given straightforward cache key (which never-ever changes given same password!):
    raw_session_cookie = if cache
                           Thread.current[key] ||= Rails::SessionCookie::WardenApp.new(user).session_cookie
                         else
                           Rails::SessionCookie::WardenApp.new(user).session_cookie
                         end
    Capybara.current_session.driver.browser.set_cookie raw_session_cookie
    visit '/home'
  end

  def devise_sign_in!
    sign_in(user)
    # NOTE: that `sign_in` by itself only postpones a block which is doing work
    # See: https://github.com/hassox/warden/blob/master/lib/warden/test/helpers.rb#L18L23
    visit '/home'
  end

  def check_expectation!
    expect(page.body).to eq %([["warden.user.user.key",[#{user_id_arr},#{digest.inspect}]]])
  end

  describe 'correctness of' do
    describe 'SessionCookie' do
      it 'is correct' do
        session_cookie!
        check_expectation!
      end
    end

    describe 'Devise Helpers' do
      it 'are correct' do
        devise_sign_in!
        check_expectation!
      end
    end
  end

  describe 'against Devise::Test::Helpers' do
    if ENV.key?('PERFORMANCE')
      it 'is not slower separately' do
        expect { session_cookie! }.not_to perform_slower_than { devise_sign_in! }
      end
    end

    it 'is not slower than devise helpers if using cache and executing multiple specs in a suite' do
      if ENV.key?('PERFORMANCE')
        n = ENV.fetch('N', 10).to_i
        expect { n.times { session_cookie! } }.not_to perform_slower_than { n.times { devise_sign_in! } }
      end

      Benchmark.ips do |x|
        x.report('devise sign_in           ') { devise_sign_in! }
        x.report('session cookie           ') { session_cookie! }
        x.report('session cookie (no cache)') { session_cookie!(false) }
        x.compare!
      end
    end
  end
end
