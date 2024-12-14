# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 6.5'
gem 'ruby-saml', '~> 1.17'
gem 'sinatra', '~> 4.1'
gem 'sinatra-contrib', '~> 4.1'

group :development do
  gem 'overcommit', '~> 0.64.1'
  gem 'rubocop', '~> 1.69.2'
  gem 'rubocop-rspec', '~> 3.3'
end

group :test do
  gem "rspec_junit_formatter", require: false
  gem 'rack-test', '~> 2.1'
  gem 'rspec', '~> 3.13', group: :test
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.24'
end

gem 'pry', '~> 0.15.0', group: %i[development test]
