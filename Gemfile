# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 7.2'
gem 'ruby-saml', '~> 1.18'
gem 'sinatra', '~> 4.2'
gem 'sinatra-contrib', '~> 4.1'

group :development do
  gem 'overcommit', '~> 0.68.0'
  gem 'rubocop', '~> 1.84.2'
  gem 'rubocop-rspec', '~> 3.9'
end

group :test do
  gem "rspec_junit_formatter", require: false
  gem 'rack-test', '~> 2.2'
  gem 'rspec', '~> 3.13', group: :test
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.26'
end

gem 'pry', '~> 0.16.0', group: %i[development test]
