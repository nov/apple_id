module AppleID
  class IdToken < OpenIDConnect::ResponseObject::IdToken
    class VerificationFailed < StandardError; end

    def verify!(expected_client, access_token: nil, code: nil, verify_signature: true)
      verify_signature! if verify_signature
      verify_claims! expected_client, access_token, code
      self
    end

    class << self
      def decode(jwt_string)
        super jwt_string, :skip_verification
      end
    end

    private

    def jwks
      @jwks ||= JSON.parse(
        OpenIDConnect.http_client.get_content(JWKS_URI)
      ).with_indifferent_access
      JSON::JWK::Set.new @jwks[:keys]
    end

    def verify_signature!
      raw_attributes.verify! jwks
    rescue
      raise VerificationFailed, 'Signature Verification Failed'
    end

    def verify_claims!(expected_client, access_token, code)
      # TODO: verify at_hash & c_hash
      unless (
        iss == ISSUER &&
        aud == expected_client.identifier &&
        Time.now.to_i.between?(iat, exp)
      )
        raise VerificationFailed, 'Claims Verification Failed'
      end
    end
  end
end
