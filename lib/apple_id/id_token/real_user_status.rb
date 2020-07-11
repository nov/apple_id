module AppleID
  class IdToken::RealUserStatus
    class UndefinedStatus < StandardError; end

    attr_accessor :value

    STATUSES = [
      :unsupported,
      :unknown,
      :likely_real
    ]

    def initialize(value)
      self.value = value
    end

    STATUSES.each do |expected_status|
      define_method :"#{expected_status}?" do
        send(:status) == expected_status
      end
    end

    def status
      STATUSES[value] or raise UndefinedStatus
    end
  end
end