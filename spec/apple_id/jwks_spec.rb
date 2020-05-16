RSpec.describe AppleID::JWKS do
  class CustomCache
    def fetch(kid)
      case kid
      when 'apple_id:jwks:known'
        File.new(File.join(File.dirname(__FILE__), '../mock_response/jwks.json'))
      else
        yield
      end
    end
  end

  describe '.cache' do
    subject { AppleID::JWKS.cache }

    context 'as default' do
      it { should be_instance_of AppleID::JWKS::Cache }
    end

    context 'when specified' do
      before { AppleID::JWKS.cache = CustomCache.new }
      after { AppleID::JWKS.cache = AppleID::JWKS::Cache.new }
      it { should be_instance_of CustomCache }
    end
  end

  describe '.fetch' do
    subject { AppleID::JWKS.fetch kid }

    before { AppleID::JWKS.cache = CustomCache.new }
    after { AppleID::JWKS.cache = AppleID::JWKS::Cache.new }

    context 'when unknown' do
      let(:kid) { 'unknown' }
      it "should request to #{AppleID::JWKS_URI}" do
        expect do
          subject
        end.to request_to AppleID::JWKS_URI
      end
    end

    context 'when known' do
      let(:kid) { 'known' }
      it "should not request to #{AppleID::JWKS_URI}" do
        expect do
          subject
        end.not_to request_to AppleID::JWKS_URI
      end
    end
  end
end