# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 6.4'
gem 'ruby-saml', '~> 1.16'
gem 'sinatra', '~> 4.0'
gem 'sinatra-contrib', '~> 4.0'

group :development do
  gem 'overcommit', '~> 0.62.0'
  gem 'rubocop', '~> 1.60.1'
  gem 'rubocop-rspec', '~> 2.26'
end

group :test do
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.12', group: :test
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.19'
end

gem 'pry', '~> 0.14.2', group: %i[development test]
