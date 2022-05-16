# frozen_string_literal: true

require 'benchmark/ips'
require 'spec_helper'

RSpec.describe 'Speed using custom sign-in in request test', type: :request, performance: true do
  include RSpec::Benchmark::Matchers

  let(:password) { '123123' }
  let(:email) { 'ad@ad.ad' }

  let!(:user) { User.find_by(email: email) || User.create!(email: email, password: password) }
  let!(:session_data) { %([["current_user_id",#{user.id}]]) }
  let(:key) { "request:user:#{user.id}" }

  def session_cookie!(cache = true)
    # Given straightforward cache key (which never-ever changes given same password!):
    raw_session_cookie = if cache
                           Thread.current[key] ||=
                             Rails::SessionCookie::App.new(current_user_id: user.id).session_cookie
                         else
                           Rails::SessionCookie::App.new(current_user_id: user.id).session_cookie
                         end
    cookies.merge(raw_session_cookie)
  end

  def custom_sign_in!
    auth_data = { email: email, password: password }
    post '/custom_sign_in', params: auth_data
  end

  def check_expectation!
    get '/home'
    expect(response.body).to eq session_data
  end

  describe 'correctness of' do
    describe 'SessionCookie' do
      it 'is correct' do
        session_cookie!
        check_expectation!
      end
    end

    describe 'usual session controller' do
      it 'is correct' do
        custom_sign_in!
        check_expectation!
      end
    end
  end

  describe 'against custom sign in route' do
    it 'is faster separately without cache' do
      expect { session_cookie! }.not_to perform_slower_than { custom_sign_in! } if ENV.key?('PERFORMANCE')

      Benchmark.ips do |x|
        x.report('custom sign in           ') { custom_sign_in! }
        x.report('session cookie           ') { session_cookie! }
        x.report('session cookie (no cache)') { session_cookie!(false) }
        x.compare!
      end
    end
  end
end
