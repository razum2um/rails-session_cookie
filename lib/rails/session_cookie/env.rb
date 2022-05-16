# frozen_string_literal: true

require 'action_dispatch'
require 'active_support'

module Rails
  module SessionCookie
    # This merges proper key generator if SECRET_KEY_BASE is explicit
    # and generates additional request env
    class Env
      def self.rails_key_generator(secret_key_base)
        ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000))
      end

      def initialize(env = nil)
        @env = env || {}
      end

      def env
        return @env unless secret_key_base

        @env.merge(
          ActionDispatch::Cookies::SECRET_KEY_BASE => secret_key_base,
          ActionDispatch::Cookies::GENERATOR_KEY => key_generator
        )
      end

      private

      # rails caches secret_key_base and key_generator
      def key_generator
        self.class.rails_key_generator(secret_key_base)
      end

      def secret_key_base
        @secret_key_base ||= @env.fetch(:secret_key_base, nil) || @env.fetch(ActionDispatch::Cookies::SECRET_KEY_BASE, nil)
      end
    end
  end
end
