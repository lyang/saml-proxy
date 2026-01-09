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

  get '/health-check' do
    OneLogin::RubySaml::Authrequest.new.create(saml_settings)
    200
  end

  private

  def saml_settings
    self.class.saml_settings ||= load_saml_settings
  end

  def valid?(saml_response)
    csrf = session[:csrf]
    relay = params[:RelayState]

    return false if csrf.nil? || relay.nil?

    saml_response.is_valid? && Rack::Utils.secure_compare(csrf, relay)
  end

  def parse_priority(value)
    case value
    when Array
      value.map(&:to_s)
    when String
      # Accept comma, pipe, or whitespace separated lists
      value.split(/[,\|\s]+/)
    else
      []
    end.map(&:strip).reject(&:empty?)
  end

  def update_session(saml_response)
    session[:authed] = true
    session[:mappings] = {}

    # Configurable priority order (array of role names)
    role_priority = parse_priority(settings.groups[:priority])

    settings.mappings.each do |attr, header|
      if attr == settings.groups[:attribute]
        roles = saml_response.attributes
                             .multi(attr)
                             .map { |group_id| settings.groups[:mappings][group_id] }
                             .compact
                             .map(&:to_s)
                             .map(&:strip)
                             .reject(&:empty?)
                             .uniq

        selected = role_priority.find { |r| roles.include?(r) } || roles.first
        halt 401 unless selected
        session[:mappings][header] = selected.to_s
      else
        session[:mappings][header] = saml_response.attributes[attr]
      end
    end
  end
end
