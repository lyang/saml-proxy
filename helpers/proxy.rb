# frozen_string_literal: true

require 'open-uri'

# Helper methods to load proxy settings
module ProxyHelper
  def proxy_config
    settings.proxy.deep_symbolize_keys.compact
  end

  def proxy_settings
    if proxy_config.empty?
      {}
    elsif proxy_config.key?(:user)
      { proxy_http_basic_authentication: authenticated_proxy }
    else
      { proxy: parse_proxy }
    end
  end

  def authenticated_proxy
    [parse_proxy, proxy_config[:user], proxy_config[:pass]]
  end

  def parse_proxy
    URI.parse(proxy_config[:host]).tap do |proxy|
      proxy.port = proxy_config[:port] if proxy_config.key?(:port)
    end
  end
end
