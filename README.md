# Rails::SessionCookie


## Installation

```ruby
# Gemfile
gem 'rails-session_cookie', group: :test
```

## Usage

```ruby
# spec_helper.rb
require 'rails/session_cookie'
before(:each, authenticated: true) do
  raw_session_cookie = Rails::SessionCookie::App.new(current_user_id: 1).session_cookie
  # depending on Rails version and session configuration
  # raw_session_cookie = "cookie_store_key=data--digest; path=/; HttpOnly"
  cookies.merge(raw_session_cookie)
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/razum2um/rails-session_cookie.
