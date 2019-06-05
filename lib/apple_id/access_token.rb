module AppleID
  class AccessToken < OpenIDConnect::AccessToken
    undef_required_attributes :client

    def initialize(access_token, attributes = {})
      super attributes.merge(access_token: access_token)
      self.id_token = IdToken.decode(id_token) if id_token.present?
    end
  end
end
