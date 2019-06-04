module AppleID
  class Client < OpenIDConnect::Client
    attr_required :team_id, :key_id, :private_key

    def initialize(attributes)
      attributes_with_default = {
        host: 'appleid.apple.com',
        authorization_endpoint: '/auth/authorize',
        token_endpoint: '/auth/token'
      }.merge(attributes)
      super attributes_with_default
    end

    def access_token!(options = {})
      self.secret = client_secret_jwt
      super :body, options
    end

    private

    def client_secret_jwt
      jwt = JSON::JWT.new(
        iss: team_id,
        aud: AppleID::ISSUER,
        sub: identifier,
        iat: Time.now,
        exp: 1.minutes.from_now
      )
      jwt.kid = key_id
      jwt.sign(private_key)
    end
  end
end