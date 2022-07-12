module AppleID
  class EventToken < OpenIDConnect::ConnectObject
    class VerificationFailed < Error; end

    # NOTE: Apple uses `events` for the JWT key, but this gem uses `event` since it's always a single JSON Object.
    #       Once they start returning an array of events, this gem might use `events` as the attribute name.
    attr_required :iss, :aud, :exp, :iat, :jti, :event
    alias_method :original_jwt, :raw_attributes

    def initialize(attributes = {})
      super
      @event = Event.decode attributes[:events]
    end

    def verify!(verify_signature: true, client: nil)
      verify_signature! if verify_signature
      verify_claims! client, nonce, state, access_token, code
      self
    end

    class << self
      def decode(jwt_string)
        new JSON::JWT.decode jwt_string, :skip_verification
      end
    end

    private

    def verify_signature!
      original_jwt.verify! JWKS.fetch(original_jwt.kid)
    rescue
      raise VerificationFailed, 'Signature Verification Failed'
    end

    def verify_claims!(client, nonce, state, access_token, code)
      aud = if client.respond_to?(:identifier)
        client.identifier
      else
        client
      end

      failure_reasons = []
      if self.iss != ISSUER
        failure_reasons << :iss
      end
      if aud.present? && self.aud != aud
        failure_reasons << :aud
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