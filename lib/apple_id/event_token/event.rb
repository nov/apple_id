module AppleID
  class EventToken::Event < OpenIDConnect::ConnectObject
    attr_required :type, :sub, :event_time
    attr_optional :email, :is_private_email

    module Type
      EMAIL_ENABLED   = 'email-enabled'
      EMAIL_DISABLED  = 'email-disabled'
      CONSENT_REVOKED = 'consent-revoked'
      ACCOUNT_DELETED = 'account-delete'
    end

    def email_enabled?
      type == Type::EMAIL_ENABLED
    end

    def email_disabled?
      type == Type::EMAIL_DISABLED
    end

    def consent_revoked?
      type == Type::CONSENT_REVOKED
    end

    def account_deleted?
      type == Type::ACCOUNT_DELETED
    end
    alias_method :account_delete?, :account_deleted?

    def is_private_email?
      if is_private_email.is_a? String
        is_private_email == 'true'
      else
        !!is_private_email
      end
    end

    class << self
      def decode(json_string)
        new JSON.parse(json_string).with_indifferent_access
      end
    end
  end
end