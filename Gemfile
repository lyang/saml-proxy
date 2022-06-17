# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 5.6'
gem 'ruby-saml', '~> 1.14'
gem 'sinatra', '~> 2.2'
gem 'sinatra-contrib', '~> 2.2'

group :development do
  gem 'overcommit', '~> 0.59.1'
  gem 'rubocop', '~> 1.30.1'
  gem 'rubocop-rspec', '~> 2.11'
end

group :test do
  gem 'rack-test', '~> 1.1'
  gem 'rspec', '~> 3.11', group: :test
  gem 'simplecov', '~> 0.21.2'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.14'
end

gem 'pry', '~> 0.14.1', group: %i[development test]
