# frozen_string_literal: true

# rubocop:disable Lint/SuppressedException
begin
  require 'warden'
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

require 'rails/session_cookie/app'

module Rails
  module SessionCookie
    # This mini rack app helps setting warden session cookie
    class WardenApp < App
      def initialize(user, session_options = nil, scope = :user)
        auth_session_options = session_options || rails_app.config.session_options
        serializer = Warden::SessionSerializer.new({})

        key = serializer.key_for(scope)
        value = serializer.store(user, scope)

        auth_app = proc { |env|
          env[Rails::SessionCookie::RACK_SESSION][key] = value
          [200, {}, []]
        }

        super(auth_app, auth_session_options)
      end
    end
  end
end
