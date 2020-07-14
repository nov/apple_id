RSpec.describe AppleID::API::UserMigration do
  API_ENDPOINT = File.join(AppleID::ISSUER, '/auth/usermigrationinfo')

  subject { request }
  let(:client) do
    AppleID::Client.new(
      identifier: 'client_id',
      team_id: 'team_id',
      key_id: 'key_id',
      private_key: OpenSSL::PKey::EC.generate('prime256v1')
    )
  end
  let(:access_token) { AppleID::AccessToken.new('token', client: client) }

  describe '#transfer_from!' do
    let(:request) do
      access_token.transfer_from!(
        transfer_sub: 'transfer_sub'
      )
    end

    it "should POST to #{API_ENDPOINT}" do
      expect do
        request
      end.to request_to API_ENDPOINT, :post
    end
  end

  describe '#transfer_to!' do
    let(:request) do
      access_token.transfer_to!(
        sub: 'sub',
        target: 'target'
      )
    end

    it "should POST to #{API_ENDPOINT}" do
      expect do
        request
      end.to request_to API_ENDPOINT, :post
    end
  end
end
