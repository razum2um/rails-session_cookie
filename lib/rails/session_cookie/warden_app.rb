require 'warden'
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

        @app = with_middlewares(auth_app, auth_session_options)
      end
    end
  end
end
