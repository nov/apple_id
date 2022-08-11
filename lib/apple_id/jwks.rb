module AppleID
  class JWKS < JSON::JWK::Set
    def self.cache=(cache)
      JSON::JWK::Set::Fetcher.cache = cache
    end
    def self.cache
      JSON::JWK::Set::Fetcher.cache
    end

    def self.fetch(kid)
      JSON::JWK::Set::Fetcher.fetch JWKS_URI, kid: kid
    end
  end
end