# frozen_string_literal: true

require 'sinatra'
require 'sinatra/config_file'
require 'onelogin/ruby-saml'
require 'open-uri'
require_relative 'hash'

# Simple Saml2 SSO proxy like oauth2-proxy
class SamlProxy < Sinatra::Base
  class << self
    attr_accessor :saml_settings
  end

  HTTP_REDIRECT = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'

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

    use Rack::Session::Cookie, settings.cookie.deep_symbolize_keys.compact unless test?
  end

  get '/auth' do
    if session[:authed]
      [200, session[:mappings], '']
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
      update_session(saml_response)
      redirect session.delete(:redirect)
    else
      401
    end
  end

  private

  def saml_settings
    self.class.saml_settings ||= load_saml_settings
  end

  def load_saml_settings
    apply_metadata(
      OneLogin::RubySaml::Settings.new(
        settings.saml.deep_symbolize_keys,
        true
      )
    )
  end

  def apply_metadata(saml_settings)
    if settings.saml.key?(:idp_metadata)
      OneLogin::RubySaml::IdpMetadataParser.new.parse(
        load_metadata(settings.saml[:idp_metadata]),
        settings: saml_settings,
        sso_binding: [HTTP_REDIRECT]
      )
    else
      saml_settings
    end
  end

  def load_metadata(uri)
    URI.open(uri).read
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
  end
end
