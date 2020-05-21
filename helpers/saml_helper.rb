# frozen_string_literal: true

# Helper methods to load SAML settings
module SamlHelper
  HTTP_REDIRECT = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'

  def saml_config
    settings.saml
  end

  def load_saml_settings
    apply_metadata(OneLogin::RubySaml::Settings.new(saml_config, true))
  end

  def apply_metadata(settings)
    if saml_config.key?(:idp_metadata)
      OneLogin::RubySaml::IdpMetadataParser.new.parse(
        load_metadata(saml_config[:idp_metadata]),
        settings: settings,
        sso_binding: [HTTP_REDIRECT]
      )
    else
      settings
    end
  end

  def load_metadata(uri)
    URI.open(uri, **proxy_settings).read
  end
end
