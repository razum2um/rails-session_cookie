# Rails::SessionCookie

Fast, loosely coupled requests specs for a cookie-authenticated application.

[![Gem Version][GV img]][Gem Version]
[![Build Status][BS img]][Build Status]
[![Coverage][CV img]][Coverage]

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

  it 'shows private data' do
    get '/dashboard'
  end
end
```

In a usual user-driven application this tightly couples *all* request specs, which require authentication, to the login process.
If it fails - everything fails. If it's not blazingly fast - it slows the whole suite down.

One may move to token-based authentification, especially when having API. That's reasonable and nice.
But we can think about a session cookie as a token passed in a special header!

This gem replaces your usual process with the simplest 2 rails middleware pass.
Rails is modular, that's cool :)

## Installation

```ruby
# Gemfile
gem 'rails-session_cookie', group: :test
```

## Usage in requests specs

```ruby
# spec_helper.rb
require 'rails/session_cookie'

def login(current_user)
  # depending on Rails version and session configuration this looks like "cookie_store_key=data--digest; path=/; HttpOnly"
  raw_session_cookie = Rails::SessionCookie::App.new(current_user_id: current_user.id).session_cookie

  # note, it's raw, not `<<`
  cookies.merge(raw_session_cookie)
end

# ...everything else the same
```

Now you can cache `raw_session_cookie` globally or per-thread depending on `current_user_id` to get things even faster!

You can also use the `raw_session_cookie` directly like this:

```
get "/", {}, { "HTTP_COOKIE" => raw_session_cookie }
```

Strictly speaking, you may cache `Set-Cookie` response header from `/login` URL to achieve same speed (but not coupling ;)
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

Of course, you can just make use (and reuse!) of as many procs as you wish.

This effectively achieves the effect as [this PR#18230](https://github.com/rails/rails/pull/18230/files), which allows session mutation
in a less invasive way in regard to Rails itself ;)

## Warden / Devise

Getting session cookie is dead-simple, just get the cookie this way:

```ruby
raw_session_cookie = Rails::SessionCookie::WardenApp.new(user).session_cookie
```

## Feature tests using Capybara

Get the cookie as described above according to your setup, and assign this way:

```ruby
Capybara.current_session.driver.browser.set_cookie raw_session_cookie
```

*TODO:* Only tested with `:rack_test` driver!

## Benchmarks

*NOTE:* Sometimes devise's `sign_in` is still faster than `SessionCookie` (a little though),
because Warden uses an [ugly hack, in my opinion,](https://github.com/hassox/warden/blob/master/lib/warden/test/helpers.rb#L18L23)
to support test-mode authentication.

But, still, in average performance of this gem is not worse *if used with user_id->cookie caching*
Besides, authentication becomes as transparent as possible and should increase readability
if you understand HTTP session cookies principles.

```sh
$ appraisal rails-5.1-warden rspec -t performance spec/benchmarks

Speed using capybara in feature test
  correctness of
    SessionCookie
      is correct
    Devise Helpers
      are correct
  against Devise::Test::Helpers
    is obviously slower separately
    is not slower than devise helpers if using cache and executing multiple specs in a suite

Speed using custom sign-in in request test
  correctness of
    SessionCookie
      is correct
    usual session controller
      is correct
  against custom sign in route
    is faster separately without cache

Finished in 1.89 seconds (files took 0.89589 seconds to load)
7 examples, 0 failures
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/razum2um/rails-session_cookie.

[Gem Version]: https://rubygems.org/gems/rails-session_cookie
[Build Status]: https://travis-ci.org/razum2um/rails-session_cookie
[Coverage]: https://codeclimate.com/github/razum2um/rails-session_cookie/coverage

[GV img]: https://badge.fury.io/rb/rails-session_cookie.svg
[BS img]: https://travis-ci.org/razum2um/rails-session_cookie.png
[CV img]: https://codeclimate.com/github/razum2um/rails-session_cookie/badges/coverage.svg
