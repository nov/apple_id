module AppleID
  class JWKS < JSON::JWK::Set
    class Cache
      def fetch(cache_key)
        yield
      end
    end

    def self.cache=(cache)
      @@cache = cache
    end
    def self.cache
      @@cache
    end
    self.cache = Cache.new

    def self.fetch(cache_key)
      jwks = cache.fetch("apple_id:jwks:#{cache_key}") do
        new(
          JSON.parse(
            OpenIDConnect.http_client.get_content(JWKS_URI)
          ).with_indifferent_access[:keys]
        )
      end
    end
  end
end