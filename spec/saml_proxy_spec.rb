# frozen_string_literal: true

require_relative 'sinatra_spec_helper'

RSpec.describe SamlProxy do
  describe '/auth' do
    it 'returns 401 if not already authenticated' do
      get '/auth'
      expect(last_response.status).to eq(401)
    end

    it 'returns 200 if already authenticated' do
      get '/auth', {}, { 'rack.session' => { authed: true } }
      expect(last_response.status).to eq(200)
    end
  end

  describe '/start' do
    it 'sets csrf token and stores redirect target' do
      get '/start', { redirect: 'example.com' }, {}
      expect(last_request.session[:csrf]).not_to eq(nil)
    end

    it 'stores redirect target' do
      get '/start', { redirect: 'example.com' }, {}
      expect(last_request.session[:redirect]).to eq('example.com')
    end

    it 'redirects to idp_sso_target_url' do
      get '/start', { redirect: 'example.com' }, {}
      uri = URI.parse(last_response.headers['Location'])
      expect(uri.host).to eq('example.com')
    end

    it 'sets RelayState' do
      get '/start', { redirect: 'example.com' }, {}
      uri = URI.parse(last_response.headers['Location'])
      query = Rack::Utils.parse_query(uri.query)
      expect(query['RelayState']).to eq(last_request.session[:csrf])
    end
  end
end
