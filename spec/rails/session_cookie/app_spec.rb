require 'spec_helper'

RSpec.describe Rails::SessionCookie::App, type: :request do
  let(:value) { { current_user_id: 1, current_state: { key: 'time', value: Time.now } } }
  let(:expected_session_data) { JSON(value.map { |k, v| [k.to_s, v] } .sort) }

  shared_examples_for 'sets proper session' do
    it 'raises without rails application' do
      expect(Rails).to receive(:application)
      expect { subject.session_cookie } .to raise_error Rails::SessionCookie::NoRailsApplication
    end

    it 'retrieves session cookie' do
      expect(subject.session_cookie).to match Regexp.new(DebugSessionApp::COOKIE_KEY)
    end

    it 'allows to use cookie in next requests' do
      cookies.merge(subject.session_cookie)

      get '/home'
      expect(response.body).to eq expected_session_data
    end
  end

  describe '.session_cookie' do
    let(:custom_session) { raise 'assign :app in let' }
    subject { described_class.new(custom_session) }

    describe 'with session hash' do
      let(:custom_session) { value }

      it_behaves_like 'sets proper session'
    end

    describe 'with custom application' do
      let(:custom_session) do
        proc { |env|
          value.each { |k, v| env[Rails::SessionCookie::RACK_SESSION][k] = v }
          [200, {}, []]
        }
      end

      it_behaves_like 'sets proper session'
    end
  end
end
