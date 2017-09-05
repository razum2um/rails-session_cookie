require 'rspec-benchmark'
require 'spec_helper'

RSpec.describe 'Speed using custom sign-in in request test', type: :request, performance: true do
  include RSpec::Benchmark::Matchers

  let(:password) { '123123' }
  let(:email) { 'ad@ad.ad' }

  let!(:user) { User.find_by(email: email) || User.create!(email: email, password: password) }
  let!(:session_data) { User.serialize_into_session(user) }

  describe 'correctness of' do
    describe 'SessionCookie' do
      it 'is correct' do
        raw_session_cookie = Rails::SessionCookie::WardenApp.new(user).session_cookie
        cookies.merge(raw_session_cookie)

        get '/home'
        user_id_arr, digest = session_data
        expect(response.body).to eq %([["warden.user.user.key",[#{user_id_arr},#{digest.inspect}]]])
      end
    end

    describe 'usual session controller' do
      it 'is correct' do
        auth_data = { email: email, password: password }
        params = RAILS4 ? auth_data : { params: auth_data }
        post '/custom_sign_in', params

        get '/home'
        user_id_arr, digest = session_data
        expect(response.body).to eq %([["warden.user.user.key",[#{user_id_arr},#{digest.inspect}]]])
      end
    end
  end

  describe 'against custom sign in route' do
    it 'is faster separately without cache' do
      expect do
        raw_session_cookie = Rails::SessionCookie::WardenApp.new(user).session_cookie
        Capybara.current_session.driver.browser.set_cookie raw_session_cookie
      end.to perform_faster_than {
        auth_data = { email: email, password: password }
        params = RAILS4 ? auth_data : { params: auth_data }
        post '/custom_sign_in', params
      }
    end
  end
end
