module AppleID
  class EventToken::Event < OpenIDConnect::ConnectObject
    attr_required :type, :sub, :event_time

    class << self
      def decode(json_string)
        new JSON.parse(json_string).with_indifferent_access
      end
    end
  end
end