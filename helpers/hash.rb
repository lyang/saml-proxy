# frozen_string_literal: true

# Poorman's deep_symbolize_keys to workaround Sinatra::IndifferentHash
class Hash
  def deep_symbolize_keys
    each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value.is_a?(Hash) ? value.deep_symbolize_keys : value
    end
  end
end
