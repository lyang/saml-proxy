# frozen_string_literal: true

require_relative 'sinatra_spec_helper'

RSpec.describe SamlProxy do
  before do
    described_class.saml_settings = nil
  end

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
    context 'with local settings' do
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

    context 'with idp metadata' do
      let(:parser) { OneLogin::RubySaml::IdpMetadataParser.new }

      before do
        allow(OneLogin::RubySaml::IdpMetadataParser).to(
          receive(:new).and_return(parser)
        )
      end

      after do
        described_class.settings.saml.delete(:idp_metadata)
      end

      it 'loads idp metadata from remote' do
        described_class.settings.saml[:idp_metadata] = 'https://example.com/idp/metadata'
        stub_request(:get, 'https://example.com/idp/metadata')
          .to_return(status: 200, body: File.read('spec/idp_metadata.xml'))
        allow(parser).to receive(:parse).and_call_original
        get '/start', { redirect: 'example.com' }, {}
        expect(parser).to have_received(:parse)
      end

      it 'loads idp metadata from local file' do
        described_class.settings.saml[:idp_metadata] = 'spec/idp_metadata.xml'
        allow(parser).to receive(:parse).and_call_original
        get '/start', { redirect: 'example.com' }, {}
        expect(parser).to have_received(:parse)
      end

      it 'only loads idp metadata once' do
        described_class.settings.saml[:idp_metadata] = 'spec/idp_metadata.xml'
        allow(parser).to receive(:parse).and_call_original
        get '/start', { redirect: 'example.com' }, {}
        get '/start', { redirect: 'example.com' }, {}
        expect(parser).to have_received(:parse)
      end
    end
  end

  describe '/consume' do
    let(:saml_response) { instance_double(OneLogin::RubySaml::Response) }

    before do
      allow(OneLogin::RubySaml::Response).to(
        receive(:new).and_return(saml_response)
      )
    end

    context 'with invalid response' do
      it 'returns 401 if invalid saml response' do
        allow(saml_response).to receive(:is_valid?).and_return(false)
        params = { SAMLResponse: '', RelayState: 'csrf' }
        post '/consume', params, { 'rack.session' => { csrf: 'csrf' } }
        expect(last_response.status).to eq(401)
      end

      it 'returns 401 if RelayState does not match csrf token' do
        allow(saml_response).to receive(:is_valid?).and_return(true)
        params = { SAMLResponse: '', RelayState: 'forged' }
        post '/consume', params, { 'rack.session' => { csrf: 'csrf' } }
        expect(last_response.status).to eq(401)
      end
    end

    context 'with valid response' do
      let(:params) { { SAMLResponse: '', RelayState: 'csrf' } }
      let(:rack_env) do
        { 'rack.session' => { csrf: 'csrf', redirect: 'http://example.com' } }
      end

      before do
        allow(saml_response).to receive(:is_valid?).and_return(true)
      end

      it 'update session if saml response and csrf are both valid' do
        post '/consume', params, rack_env
        expect(last_request.session[:authed]).to eq(true)
      end

      it 'redirects if saml response and csrf are both valid' do
        post '/consume', params, rack_env
        expect(last_response.status).to eq(302)
      end

      it 'redirects session stored location' do
        post '/consume', params, rack_env
        expect(last_response.headers['Location']).to eq('http://example.com')
      end
    end
  end
end
