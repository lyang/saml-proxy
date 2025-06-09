# frozen_string_literal: true

source 'https://rubygems.org'

gem 'puma', '~> 6.6'
gem 'ruby-saml', '~> 1.18'
gem 'sinatra', '~> 4.1'
gem 'sinatra-contrib', '~> 4.1'

group :development do
  gem 'overcommit', '~> 0.67.1'
  gem 'rubocop', '~> 1.76.1'
  gem 'rubocop-rspec', '~> 3.6'
end

group :test do
  gem "rspec_junit_formatter", require: false
  gem 'rack-test', '~> 2.2'
  gem 'rspec', '~> 3.13', group: :test
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura'
  gem 'webmock', '~> 3.25'
end

gem 'pry', '~> 0.15.2', group: %i[development test]
