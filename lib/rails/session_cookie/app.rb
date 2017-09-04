require 'rack'
require 'active_support'
require 'action_dispatch'

module Rails
  module SessionCookie
    NoRailsApplication = Class.new(StandardError)
    RACK_SESSION = 'rack.session'.freeze # upstream constant name is changing

    # This mini rack app allows easily get rails session cookie
    class App
      def self.simple_app_from_session_hash(session = {})
        proc { |env|
          session.each do |k, v|
            env[RACK_SESSION][k] = v
          end
          [200, {}, []]
        }
      end

      attr_reader :app, :rails_app

      def initialize(app, session_options = nil)
        auth_session_options = session_options || rails_app.config.session_options
        auth_app = app.respond_to?(:call) ? app : self.class.simple_app_from_session_hash(app)
        @app = with_session_cookie_middlewares(auth_app, auth_session_options)
      end

      def call(env = default_env)
        app.call(env)
      end

      def session_cookie(env = default_env)
        _status, headers, _body = app.call(env)
        headers[ActionDispatch::Cookies::HTTP_HEADER]
      end

      private

      def with_session_cookie_middlewares(app, session_options)
        ActionDispatch::Cookies.new(
          ActionDispatch::Session::CookieStore.new(
            app, session_options
          )
        )
      end

      def default_env
        rails_app.env_config.merge('REQUEST_METHOD' => 'GET')
      end

      def rails_app
        @rails_app ||= defined?(Rails) && Rails.application || raise(NoRailsApplication)
      end
    end
  end
end
