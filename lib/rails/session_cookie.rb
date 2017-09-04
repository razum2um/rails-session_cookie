require 'rails/session_cookie/app'
require 'rails/session_cookie/warden_app' if defined? Warden
require 'rails/session_cookie/version'

module Rails
  # :nodoc:
  module SessionCookie
    NoRailsApplication = Class.new(StandardError)
    RACK_SESSION = 'rack.session'.freeze # upstream constant name is changing
  end
end
