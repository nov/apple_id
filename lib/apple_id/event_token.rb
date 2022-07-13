module AppleID
  class EventToken < OpenIDConnect::ConnectObject
    class VerificationFailed < Error; end

    attr_required :iss, :aud, :exp, :iat, :jti, :events
    alias_method :original_jwt, :raw_attributes
    alias_method :event, :events

    delegate :type, :sub, :event_time, :email_enabled?, :email_disabled?, :consent_revoked?, :account_deleted?, to: :event

    def initialize(attributes = {})
      super
      @events = Event.decode attributes[:events]
    end

    def verify!(verify_signature: true, client: nil)
      verify_signature! if verify_signature
      verify_claims! client
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

    def verify_claims!(client)
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