# frozen_string_literal: true

require 'action_dispatch'

module Rails
  module SessionCookie
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

      def self.simple_app_returning_rack(app)
        proc { |env|
          result = app.call(env)
          result.is_a?(Hash) ? [200, result, []] : result
        }
      end

      attr_reader :app

      def initialize(app, session_options = nil)
        auth_session_options = session_options || rails_app.config.session_options

        auth_app = if app.respond_to?(:call)
                     self.class.simple_app_returning_rack(app)
                   else
                     self.class.simple_app_from_session_hash(app)
                   end

        @app = with_middlewares(auth_app, auth_session_options)
      end

      def call(env = {})
        app.call(default_env.merge(Env.new(env).env).dup)
      end

      def session_cookie(env = {})
        _status, headers, _body = call(env)
        headers[ActionDispatch::Cookies::HTTP_HEADER]
      end

      private

      def with_middlewares(app, session_options)
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
        @rails_app ||= (defined?(Rails) && Rails.application) || raise(NoRailsApplication)
      end
    end
  end
end
