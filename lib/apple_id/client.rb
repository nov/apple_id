module AppleID
  class Client < OpenIDConnect::Client
    class Error < Rack::OAuth2::Client::Error; end

    attr_required :team_id, :key_id, :private_key

    def initialize(attributes)
      attributes_with_default = {
        authorization_endpoint: File.join(ISSUER, '/auth/authorize'),
        token_endpoint: File.join(ISSUER, '/auth/token')
      }.merge(attributes)
      super attributes_with_default
    end

    def access_token!(options = {})
      self.secret = client_secret_jwt
      super :body, options
    end

    def authorization_uri(params = {})
      # NOTE:
      # Apple keychain (native window) does not support space encoding
      # with '+' in url params. We have to use '%20' otherwise multiple
      # scopes will be ignored. (no email / name will be returned)
      uri = super(params.except(:scope))
      if params[:scope]
        scope_as_string = Array(params[:scope]).join(' ')
        scope_param = "&scope=#{URI.encode(scope_as_string)}"
        uri << scope_param
      end

      uri
    end

    private

    def client_secret_jwt
      jwt = JSON::JWT.new(
        iss: team_id,
        aud: ISSUER,
        sub: identifier,
        iat: Time.now,
        exp: 1.minutes.from_now
      )
      jwt.kid = key_id
      jwt.sign(private_key)
    end

    def setup_required_scope(scopes)
      # NOTE:
      #  openid_connect gem add `openid` scope automatically.
      #  However, it's not required for Sign-in with Apple.
      scopes
    end

    def handle_success_response(response)
      token_hash = JSON.parse(response.body).with_indifferent_access
      AccessToken.new token_hash.delete(:access_token), token_hash
    end

    def handle_error_response(response)
      error = JSON.parse(response.body).with_indifferent_access
      raise Error.new(response.status, error)
    end
  end
end
