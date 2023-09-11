# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 6.3'
gem 'ruby-saml', '~> 1.15'
gem 'sinatra', '~> 3.1'
gem 'sinatra-contrib', '~> 3.1'

group :development do
  gem 'overcommit', '~> 0.60.0'
  gem 'rubocop', '~> 1.56.3'
  gem 'rubocop-rspec', '~> 2.24'
end

group :test do
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.12', group: :test
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.19'
end

gem 'pry', '~> 0.14.2', group: %i[development test]
