# frozen_string_literal: true

require_relative '../sinatra_spec_helper'

RSpec.describe ProxyHelper do
  let(:app) { SamlProxy.new! }

  around do |example|
    app.settings.proxy['host'] = 'http://example.com'
    example.run
    app.settings.proxy.transform_values! { nil }
  end

  describe '#proxy_config' do
    it 'deeply symbolize keys' do
      expect(app.proxy_config[:host]).to eq('http://example.com')
    end
  end

  describe '#proxy_settings' do
    it 'uses proxy if configured' do
      expect(app.proxy_settings).to eq(proxy: URI.parse('http://example.com'))
    end

    it 'uses authenticated proxy if configured' do
      app.settings.proxy['user'] = 'user'
      expect(app.proxy_settings).to eq(
        proxy_http_basic_authentication: [URI.parse('http://example.com'), 'user', '']
      )
    end
  end
end
