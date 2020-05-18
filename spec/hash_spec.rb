# frozen_string_literal: true

require_relative '../hash'

RSpec.describe Hash do
  describe '#deep_symbolize_keys' do
    it 'converts string keys to symbol keys' do
      expect({ 'key' => 'value' }.deep_symbolize_keys).to eq(key: 'value')
    end

    it 'recursively converts string keys to symbol keys' do
      actual = { 'key' => { 'nested' => 'value' } }.deep_symbolize_keys
      expect(actual).to eq(key: { nested: 'value' })
    end
  end
end
