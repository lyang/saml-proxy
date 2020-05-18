# frozen_string_literal: true

require_relative 'sinatra_spec_helper'

RSpec.describe SamlProxy do
  describe '/auth' do
    it 'returns 401 if not already authenticated' do
      response = get '/auth'
      expect(response.status).to eq(401)
    end

    it 'returns 200 if already authenticated' do
      response = get '/auth', {}, { 'rack.session' => { 'authed' => true } }
      expect(response.status).to eq(200)
    end
  end
end
