# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails/session_cookie/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-session_cookie'
  spec.version       = Rails::SessionCookie::VERSION
  spec.authors       = ['Vlad Bokov']
  spec.email         = ['razum2um@mail.ru']

  spec.summary       = 'Mini rack-app to get raw rails session cookie'
  spec.description   = 'Helps to get proper integration tests run faster'
  spec.homepage      = 'https://github.com/razum2um/rails/session_cookie'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 4.0'
end
