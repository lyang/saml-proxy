# frozen_string_literal: true

require_relative '../sinatra_spec_helper'

RSpec.describe SamlHelper do
  let(:app) { SamlProxy.new! }

  describe '#saml_config' do
    around do |example|
      app.settings.saml['security'] = { 'authn_requests_signed' => true }
      example.run
      app.settings.saml.delete('security')
    end

    it 'deeply symbolize keys' do
      expect(app.saml_config[:security]).to eq(authn_requests_signed: true)
    end
  end
end
