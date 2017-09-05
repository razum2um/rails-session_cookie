# thanks for example: https://github.com/rails/rails/issues/27145 for AC init
# and https://gist.github.com/kany/9809730 for AR init
# and gem devise#guides/bug_report_templates/integration_test.rb for Devise init

require 'action_controller/railtie'
require 'active_record/railtie'

# rubocop:disable Lint/HandleExceptions
begin
  require 'devise'
  require 'devise/rails/routes'
  require 'devise/rails/warden_compat'
rescue LoadError
end
# rubocop:enable Lint/HandleExceptions

LEVEL = 2
LOGGER = Logger.new(IO::NULL)
LOGGER.level = LEVEL

ENV['DATABASE_URL'] = 'sqlite3::memory:'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = LOGGER

RAILS4 = Gem::Version.new(Rails.version) < Gem::Version.new('5.0')
cls = if RAILS4
        ActiveRecord::Migration
      else
        ActiveRecord::Migration[Rails.version[0..2]]
      end

class DeviseCreateUsers < cls
  def change
    create_table(:users) do |t|
      t.string :email,              null: false
      t.string :encrypted_password, null: true
      t.timestamps null: false
    end
  end
end

if defined? Devise
  Devise.setup do |config|
    require 'devise/orm/active_record'
    config.secret_key = 'devise_secret_key'
    config.parent_controller = ActionController::Base
  end
end

class DebugSessionApp < Rails::Application
  COOKIE_KEY = 'cookie_store_key'.freeze
  config.eager_load = false
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: COOKIE_KEY
  config.logger = LOGGER

  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  if defined? Devise
    config.middleware.use Warden::Manager do |config|
      Devise.warden_config = config
    end
  end
end

Rails.application.initialize! # required for Devise.warden_config
DeviseCreateUsers.migrate(:up)

class User < ActiveRecord::Base
  devise :database_authenticatable if defined? Devise
end

Rails.application.routes.draw do
  devise_for :users if defined? Devise

  post '/custom_sign_in' => 'home#custom_sign_in'
  resources :home, only: [:index]
end

class HomeController < ActionController::Base
  def index
    data = session.to_hash.except('session_id')
    render plain: JSON(data.sort)
  end

  def custom_sign_in
    user = User.find_by(email: params.require(:email))
    if user.valid_password?(params.require(:password))
      session['current_user_id'] = user.id
      render plain: 'ok'
    else
      render plain: 'wrong password'
    end
  end
end
