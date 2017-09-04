# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
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

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'appraisal', '~> 2.2'
  spec.add_development_dependency 'rubocop', '~> 0.49'
  spec.add_development_dependency 'rspec-rails', '~> 3.6.1'
  spec.add_development_dependency 'codeclimate-test-reporter', '= 1.0.8'
  spec.add_development_dependency 'simplecov', '= 0.13.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3'

  # bench
  spec.add_development_dependency 'rspec-benchmark', '~> 0.3'
  spec.add_development_dependency 'capybara', '~> 2.15'
end
