# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 6.1'
gem 'ruby-saml', '~> 1.15'
gem 'sinatra', '~> 3.0'
gem 'sinatra-contrib', '~> 3.0'

group :development do
  gem 'overcommit', '~> 0.60.0'
  gem 'rubocop', '~> 1.48.1'
  gem 'rubocop-rspec', '~> 2.19'
end

group :test do
  gem 'rack-test', '~> 2.0'
  gem 'rspec', '~> 3.12', group: :test
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.18'
end

gem 'pry', '~> 0.14.2', group: %i[development test]
