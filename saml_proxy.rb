# frozen_string_literal: true

require 'sinatra'
require 'sinatra/config_file'
require 'onelogin/ruby-saml'
require 'open-uri'
require_relative 'helpers/all'

# Simple Saml2 SSO proxy like oauth2-proxy
class SamlProxy < Sinatra::Base
  helpers SamlHelper
  helpers ProxyHelper

  class << self
    attr_accessor :saml_settings
  end

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
    config_file 'config/*.erb'

    use Rack::Session::Cookie, settings.cookie.deep_symbolize_keys.compact unless test?
  end

  get '/auth' do
    if session[:authed] && session[:host] == request.env["HTTP_HOST"]
      [200, session[:mappings], '']
    else
      401
    end
  end

  get '/start' do
    session.clear
    session[:csrf] = SecureRandom.hex(64)
    session[:redirect] = params[:redirect]
    session[:host] = request.env["HTTP_HOST"]
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
      update_session(saml_response)
      redirect session.delete(:redirect)
    else
      401
    end
  end

  get '/health-check' do
    OneLogin::RubySaml::Authrequest.new.create(saml_settings)
    200
  end

  get '/logout' do
    if session[:authed] && session[:host] == request.env["HTTP_HOST"]
      settings = saml_settings
      session[:userid] = nil
      session[:authed] = nil
      session[:mappings] = nil
      logout_request = OneLogin::RubySaml::Logoutrequest.new
      relayState = session[:csrf]
      redirect logout_request.create(settings, :RelayState => relayState)
    end
  end

  private

  def saml_settings
    temp = self.class.saml_settings ||= load_saml_settings
    assertion_url = settings.saml[:assertion_consumer_service_url]
    if assertion_url.include?("%HOST%")
      temp.assertion_consumer_service_url = assertion_url.clone.sub! '%HOST%', request.env["HTTP_HOST"]
    end
    temp.sessionindex = session[:samlindex]
    unless session[:mappings].nil?
        temp.name_identifier_value = session[:mappings]["SAML_USERNAME"]
    end
    temp
  end

  def valid?(saml_response)
    saml_response.is_valid? &&
      Rack::Utils.secure_compare(session[:csrf], params[:RelayState])
  end

  def update_session(saml_response)
    session[:authed] = true
    session[:mappings] = {}
    settings.mappings.each do |attr, header|
      session[:mappings][header] = saml_response.attributes[attr]
    end
    session[:samlindex] = saml_response.sessionindex
  end
end
