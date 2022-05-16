# frozen_string_literal: true

# thanks for example: https://github.com/rails/rails/issues/27145 for AC init
# and https://gist.github.com/kany/9809730 for AR init
# and gem devise#guides/bug_report_templates/integration_test.rb for Devise init

require 'action_controller/railtie'
require 'active_record/railtie'

if DEVISE_APP
  require 'devise'
  require 'devise/rails/routes'
  require 'devise/rails/warden_compat'
end

LEVEL = 2
LOGGER = Logger.new(IO::NULL)
LOGGER.level = LEVEL

ENV['DATABASE_URL'] = 'sqlite3::memory:'
require 'sqlite3'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
Rails.logger = ActiveRecord::Base.logger = LOGGER
class CreateUsers < ActiveRecord::Migration[Rails.version[0..2]]
  def change
    create_table(:users) do |t|
      t.string :email,              null: false
      t.string :encrypted_password, null: true
      t.timestamps null: false
    end
  end
end
CreateUsers.migrate(:up)

if DEVISE_APP
  Devise.setup do |config|
    require 'devise/orm/active_record'
    config.secret_key = 'devise_secret_key'
    config.parent_controller = ActionController::Base
  end
end

class DebugSessionApp < Rails::Application
  COOKIE_KEY = 'cookie_store_key'
  config.eager_load = false
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: COOKIE_KEY
  config.logger = LOGGER

  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  config.hosts << 'www.example.com' if config.respond_to?(:hosts)

  if DEVISE_APP
    config.middleware.use Warden::Manager do |_config|
      Devise.warden_config = WARDEN_CONFIG # _config
    end
  end
end

class User < ActiveRecord::Base
  devise :database_authenticatable if DEVISE_APP
end

# reload triggers `Devise.configure_warden!` earlier than it's set in middlewares
# must be before `devise_for :users`
Devise.warden_config = WARDEN_CONFIG if DEVISE_APP

Rails.application.routes.draw do
  devise_for :users if DEVISE_APP

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
    raise unless user.valid_password?(params.require(:password))

    session['current_user_id'] = user.id
    render plain: 'ok'
  end
end
