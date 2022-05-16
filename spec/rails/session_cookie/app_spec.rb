# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rails::SessionCookie::App, type: :request do
  let(:value) { { current_user_id: 1, current_state: { key: 'time', value: Time.now } } }

  shared_examples_for 'sets proper session' do
    it 'raises without rails application' do
      expect(Rails).to receive(:application)
      expect { subject.session_cookie }.to raise_error Rails::SessionCookie::NoRailsApplication
    end

    it 'retrieves session cookie' do
      expect(subject.session_cookie).to match Regexp.new(DebugSessionApp::COOKIE_KEY)
    end

    it 'allows to use cookie in next requests' do
      cookies.merge(subject.session_cookie)

      get '/home'
      expect(response.body).to eq dumped_session(value)
    end
  end

  describe '#session_cookie' do
    let(:custom_session) { value }
    subject { described_class.new(custom_session) }

    describe 'with session hash' do
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

    describe 'when passed additional params to auth application' do
      let(:context) { { key: 'value' } }
      let(:custom_session) do
        proc { |env|
          value.each { |k, v| env[Rails::SessionCookie::RACK_SESSION][k] = v }
          # do your sesion magic
          env[Rails::SessionCookie::RACK_SESSION].merge!(context)
          [200, {}, []]
        }
      end

      it 'stores everything into session cookie' do
        cookies.merge(subject.session_cookie)

        get '/home'
        expect(response.body).to eq dumped_session(value.merge(context))
      end
    end

    describe 'when passed explicit SECRET_KEY_BASE' do
      let(:random_secret_key_base) { SecureRandom.hex(8) }
      let(:random_key_generator) { Rails::SessionCookie::Env.rails_key_generator(random_secret_key_base) }

      before do
        allow(Rails.application.secrets).to receive(:secret_key_base) { random_secret_key_base }
        allow(Rails.application).to receive(:key_generator) { random_key_generator }
        env_config = Rails.application.env_config
        allow(Rails.application).to receive(:env_config) do
          env_config.merge(
            'action_dispatch.secret_key_base' => random_secret_key_base,
            'action_dispatch.key_generator' => random_key_generator
          )
        end
      end

      it 'sets proper cookie' do
        cookies.merge(subject.session_cookie(secret_key_base: random_secret_key_base))

        get '/home'
        expect(response.body).to eq dumped_session(value)
      end
    end
  end
end
