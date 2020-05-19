# frozen_string_literal: true

require 'sinatra'
require 'sinatra/config_file'
require 'onelogin/ruby-saml'
require_relative 'hash'

# Simple Saml2 SSO proxy like oauth2-proxy
class SamlProxy < Sinatra::Base
  configure :development, :test do
    require 'pry'
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  configure :test do
    OneLogin::RubySaml::Logging.logger.level = Logger::UNKNOWN
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

  get '/start' do
    session.clear
    session[:csrf] = SecureRandom.hex(64)
    session[:redirect] = params[:redirect]
    redirect OneLogin::RubySaml::Authrequest.new.create(
      saml_settings,
      RelayState: session[:csrf]
    )
  end

  post '/consume' do
    saml_response = OneLogin::RubySaml::Response.new(
      params[:SAMLResponse],
      settings: saml_settings
    )
    if valid?(saml_response)
      session[:authed] = true
      redirect session.delete(:redirect)
    else
      401
    end
  end

  private

  def saml_settings
    OneLogin::RubySaml::Settings.new(
      settings.saml.deep_symbolize_keys,
      true
    )
  end

  def valid?(saml_response)
    saml_response.is_valid? &&
      Rack::Utils.secure_compare(session[:csrf], params[:RelayState])
  end
end
