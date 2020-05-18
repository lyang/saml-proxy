# frozen_string_literal: true

require 'sinatra'
require 'sinatra/config_file'
require_relative 'hash'

# Simple Saml2 SSO proxy like oauth2-proxy
class SamlProxy < Sinatra::Base
  configure :development do
    require 'pry'
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  configure do
    enable :logging
    register Sinatra::ConfigFile
    config_file 'config/*'

    unless test?
      use Rack::Session::Cookie, settings.cookie.deep_symbolize_keys.compact
    end
  end

  get '/auth' do
    if session[:authed]
      200
    else
      401
    end
  end
end
