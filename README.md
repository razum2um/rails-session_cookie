# Rails::SessionCookie

Fast, loosely coupled requests specs for cookie authentificated application.

## Why

Probably, you might have seen a lot code like this:

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store

# authentificaing method (maybe Devise or whatever)
session[:current_user_id] = current_user.id

# somewhere in helper for request specs
def login(current_user)
  post '/login', auth_data(current_user)
end

# now every request spec is calling login request
RSpec.describe 'User inferface', type: :request do
  let(:user) { create :user }

  before do
    login(user)
  end

  it 'private data' do
    get '/dashboard'
  end
end
```

In a usual user-driven application this tightly couples *all* request specs, which require cookie authentication, to login process.
If it fails - everything fails. If it's not blazing fast - it slows the whole suite down.

One may move to token-based authentification, especially when having API. That's reasonable and nice.
But we can think about a session cookie as a token passed in a special header!

This gem replaces your usual process with the simplest 2 rails middleware pass.
Rails is modular, that's cool :)

## Installation

```ruby
# Gemfile
gem 'rails-session_cookie', group: :test
```

## Usage

```ruby
# spec_helper.rb
require 'rails/session_cookie'

def login(current_user)
  # depending on Rails version and session configuration
  # "cookie_store_key=data--digest; path=/; HttpOnly"
  raw_session_cookie = Rails::SessionCookie::App.new(current_user_id: current_user.id).session_cookie

  # note, not `<<`
  cookies.merge(raw_session_cookie)
end

# ...everything else the same
```

Now you can cache `raw_session_cookie` globally or per-thread depending on `current_user_id` to get things even more faster!

Strictly speaking, you may cache `Set-Cookie` response header from `/login` url to achieve same speed (but not coupling ;)
However, never saw this in practice, and consider caching of requests in before-phase bad. YMMV.

## Advanced usage

If you need more sophisticated logic:

```ruby
  auth_app = proc { |env|
    # do your magic
    env[Rails::SessionCookie::RACK_SESSION].merge!(context)
    [200, {}, []]
  }
  raw_session_cookie = Rails::SessionCookie::App.new(auth_app).session_cookie
end
```

Of course, you can just make use of as many procs as you wish.

This effectively achives same effect as [this PR#18230](https://github.com/rails/rails/pull/18230/files), which allows session mutation
in a less invasive way ;)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/razum2um/rails-session_cookie.
