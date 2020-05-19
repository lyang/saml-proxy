# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'spec_helper'
require 'rack/test'
require_relative '../saml_proxy'

# Auto set app to described_class
module SinatraSpecMixin
  include Rack::Test::Methods
  def app
    described_class
  end
end

RSpec.configure { |config| config.include SinatraSpecMixin }
