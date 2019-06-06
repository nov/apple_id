module AppleID
  class IdToken < OpenIDConnect::ResponseObject::IdToken
    class VerificationFailed < StandardError; end

    alias_method :original_jwt, :raw_attributes

    def verify!(verify_signature: true, client: nil, nonce: nil, state: nil, access_token: nil, code: nil)
      verify_signature! if verify_signature
      verify_claims! client, nonce, state, access_token, code
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
      original_jwt.verify! jwks
    rescue
      raise VerificationFailed, 'Signature Verification Failed'
    end

    def verify_claims!(client, nonce, state, access_token, code)
      aud = if client.respond_to?(:identifier)
        client.identifier
      else
        client
      end

      hash_length = original_jwt.alg.to_s[2, 3].to_i
      s_hash = if state.present?
        left_half_hash_of state, hash_length
      end
      at_hash = if access_token.present?
        left_half_hash_of access_token, hash_length
      end
      c_hash = if code.present?
        left_half_hash_of code, hash_length
      end

      failure_reasons = []
      if self.iss != ISSUER
        failure_reasons << :iss
      end
      if aud.present? && self.aud != aud
        failure_reasons << :aud
      end
      if nonce.present? && self.nonce != nonce
        failure_reasons << :nonce
      end
      if s_hash.present? && self.s_hash != s_hash
        failure_reasons << :s_hash
      end
      if at_hash.present? && self.at_hash != at_hash
        failure_reasons << :at_hash
      end
      if c_hash.present? && self.c_hash != c_hash
        failure_reasons << :c_hash
      end
      if Time.now.to_i < iat
        failure_reasons << :iat
      end
      if Time.now.to_i >= exp
        failure_reasons << :exp
      end

      if failure_reasons.present?
        raise VerificationFailed, "Claims Verification Failed at #{failure_reasons}"
      end
    end
  end
end
