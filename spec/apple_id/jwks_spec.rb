RSpec.describe AppleID::JWKS do
  class CustomCache
    def fetch(kid, options = {})
      case kid
      when 'json:jwk:set:f36d9dc4ef8c2f4824f813d6e568e35f:AIDOPK1'
        File.read(File.join(File.dirname(__FILE__), '../mock_response/jwks.json'))
      else
        yield
      end
    end
  end

  describe '.cache' do
    subject { AppleID::JWKS.cache }

    context 'as default' do
      it { should be_instance_of JSON::JWK::Set::Fetcher::Cache }
    end

    context 'when specified' do
      around do |example|
        original = AppleID::JWKS.cache
        AppleID::JWKS.cache = CustomCache.new
        example.run
        AppleID::JWKS.cache = original
      end
      it { should be_instance_of CustomCache }
    end
  end

  describe '.fetch' do
    subject { AppleID::JWKS.fetch kid }

    around do |example|
      original = AppleID::JWKS.cache
      AppleID::JWKS.cache = CustomCache.new
      example.run
      AppleID::JWKS.cache = original
    end

    context 'when unknown' do
      let(:kid) { 'unknown' }
      it "should request to #{AppleID::JWKS_URI}" do
        expect do
          subject
        end.to request_to AppleID::JWKS_URI
      end
    end

    context 'when known' do
      let(:kid) { 'AIDOPK1' }
      it "should not request to #{AppleID::JWKS_URI}" do
        expect do
          subject
        end.not_to request_to AppleID::JWKS_URI
      end
    end
  end
end