require 'spec_helper'

RSpec.feature 'Speed using capybara in feature test', performance: true do
  include RSpec::Benchmark::Matchers
  include Devise::Test::IntegrationHelpers

  let!(:user) { User.create!(email: 'ad@ad.ad', password: '123123') }
  let!(:session_data) { User.serialize_into_session(user) }

  describe 'correctness of' do
    describe 'SessionCookie' do
      it 'is correct' do
        raw_session_cookie = Rails::SessionCookie::WardenApp.new(user).session_cookie
        Capybara.current_session.driver.browser.set_cookie raw_session_cookie

        visit '/home'
        user_id_arr, digest = session_data
        expect(page.body).to eq %([["warden.user.user.key",[#{user_id_arr},#{digest.inspect}]]])
      end
    end

    describe 'Devise Helpers' do
      it 'are correct' do
        sign_in(user)

        visit '/home'
        user_id_arr, digest = session_data
        expect(page.body).to eq %([["warden.user.user.key",[#{user_id_arr},#{digest.inspect}]]])
      end
    end
  end

  describe 'against Devise::Test::Helpers' do
    it 'is obviously slower separately' do
      expect do
        sign_in(user)
        # NOTE: that `sign_in` by itself only postpones a block which is doing work
        # See: https://github.com/hassox/warden/blob/master/lib/warden/test/helpers.rb#L18L23
        visit '/home'
      end.to perform_faster_than {
        raw_session_cookie = Rails::SessionCookie::WardenApp.new(user).session_cookie
        Capybara.current_session.driver.browser.set_cookie raw_session_cookie
        visit '/home'
      }
    end

    it 'is not slower than devise helpers if using cache and executing multiple specs in a suite' do
      N = (ENV['N'] || 50).to_i
      key = "user:#{user.id}"

      expect do
        (0..N).each do
          # Given straightforward cache key (which never-ever changes given same password!):
          raw_session_cookie = Thread.current[key] ||= Rails::SessionCookie::WardenApp.new(user).session_cookie

          Capybara.current_session.driver.browser.set_cookie raw_session_cookie
          visit '/home'
        end
      end.not_to perform_slower_than {
        (0..N).each do
          sign_in(user)
          # NOTE: that `sign_in` by itself only postpones a block which is doing work
          # See: https://github.com/hassox/warden/blob/master/lib/warden/test/helpers.rb#L18L23
          visit '/home'
        end
      }
    end
  end
end
