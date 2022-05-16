# frozen_string_literal: true

require 'rails/session_cookie/env'
require 'rails/session_cookie/app'
require 'rails/session_cookie/warden_app'
require 'rails/session_cookie/version'

module Rails
  # :nodoc:
  module SessionCookie
    NoRailsApplication = Class.new(StandardError)
    RACK_SESSION = 'rack.session' # upstream constant name is changing
  end
end
