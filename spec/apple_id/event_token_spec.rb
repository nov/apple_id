RSpec.describe AppleID::EventToken do
  let(:jwt_header) { 'eyJraWQiOiJmaDZCczhDIiwiYWxnIjoiUlMyNTYifQ' }
  let(:jwt_payload) do
    Base64.urlsafe_encode64 jwt_claims.to_json, padding: false
  end
  let(:jwt_claims) do
    {
      iss: iss,
      aud: aud,
      exp: exp,
      iat: iat,
      jti: jti,
      events: events
    }
  end
  let(:jwt_signature) do
    'mISnuaalVknFGRHBwPIkN26n78uBW2uicijX2R_5myHrepPrNGhj1V0VRBFHPts_MZ5ofrqJ1y5ZxNHcuahv5bp7ytrAOslnBCaTaxQXZu2DWgiOw0I1XmBJ9zdZZbsWr8Godwv4PX933SdJuaevpcQDLkDxd33vFfNm9Xk_cotKQ12PjqmP535d94cppyVKE-APyYTpTxC7A4f2Lrf4Okka4A-62CgjYqFA4txhNyAvP7Ir-6AlHdnn9ASWwKGysZW987h6PhZNQJcOYSDgKXS7m5rw2noksjhWw6qt7ggP3Lm-b3PqY1Am0vIkx_biCUvnHBjWXwCkXFQDNbPRsg'
  end
  let(:jwt_string) do
    [jwt_header, jwt_payload, jwt_signature].join('.')
  end
  let(:iss) { AppleID::ISSUER }
  let(:aud) { 'jp.yauth.signin.app' }
  let(:exp) { 1657703492 }
  let(:iat) { 1657617092 }
  let(:jti) { 'S25cB0PbHs6y97gYYmgydQ' }
  let(:events) do
    '{"type":"consent-revoked","sub":"000768.6166f031167141e695698239959f591a.1521","event_time":1657617063012}'
  end
  let(:event_token) do
    AppleID::EventToken.decode jwt_string
  end

  describe '.parse' do
    subject { event_token }

    it { should be_instance_of AppleID::EventToken }
    its(:iss) { should == iss }
    its(:aud) { should == aud }
    its(:exp) { should == exp }
    its(:iat) { should == iat }
    its(:jti) { should == jti }
    [:event, :events].each do |attr|
      its(attr) { should be_instance_of AppleID::EventToken::Event }
      describe attr do
        subject { event_token.send attr }
        its(:type) { should == AppleID::EventToken::Event::Type::CONSENT_REVOKED }
        its(:sub) { should == '000768.6166f031167141e695698239959f591a.1521' }
        its(:event_time) { should == 1657617063012 }
      end
    end
  end

  describe '#verify!' do
    context 'with signature verification' do
      subject { event_token.verify! }

      around do |example|
        mock_json :get, AppleID::JWKS_URI, 'jwks' do
          example.run
        end
      end

      context 'when valid' do
        around do |example|
          travel_to(Time.at event_token.iat) do
            example.run
          end
        end

        it { should be_instance_of AppleID::EventToken }
      end

      context 'when signature invalid' do
        let(:jwt_signature) { Base64.urlsafe_encode64 'invalid' }

        it do
          expect do
            subject
          end.to raise_error AppleID::EventToken::VerificationFailed, 'Signature Verification Failed'
        end
      end

      context 'when exp invalid' do
        around do |example|
          travel_to(Time.at event_token.exp + 1) do
            example.run
          end
        end

        it do
          expect do
            subject
          end.to raise_error AppleID::EventToken::VerificationFailed, 'Claims Verification Failed at [:exp]'
        end
      end

      context 'when iat invalid' do
        around do |example|
          travel_to(Time.at event_token.iat - 1) do
            example.run
          end
        end

        it do
          expect do
            subject
          end.to raise_error AppleID::EventToken::VerificationFailed, 'Claims Verification Failed at [:iat]'
        end
      end
    end

    context 'without signature verification' do
      subject { event_token.verify! verify_signature: false }

      context 'when iss invalid' do
        let(:iss) { 'invalid' }

        it do
          expect do
            subject
          end.to raise_error AppleID::EventToken::VerificationFailed, 'Claims Verification Failed at [:iss]'
        end
      end

      context 'with client context' do
        subject { event_token.verify! verify_signature: false, client: client }

        context 'when aud valid' do
          let(:client) { aud }

          it { should be_instance_of AppleID::EventToken }

          context 'when AppleID::Client given' do
            let(:client) do
              AppleID::Client.new(
                identifier: aud,
                team_id: 'fake',
                key_id: 'fake',
                private_key: 'fake'
              )
            end

            it { should be_instance_of AppleID::EventToken }
          end
        end

        context 'when aud invalid' do
          let(:client) { 'invalid_client_id' }

          it do
            expect do
              subject
            end.to raise_error AppleID::EventToken::VerificationFailed, 'Claims Verification Failed at [:aud]'
          end

          context 'when AppleID::Client given' do
            let(:client) do
              AppleID::Client.new(
                identifier: 'invalid_client_id',
                team_id: 'fake',
                key_id: 'fake',
                private_key: 'fake'
              )
            end

            it do
              expect do
                subject
              end.to raise_error AppleID::EventToken::VerificationFailed, 'Claims Verification Failed at [:aud]'
            end
          end
        end
      end
    end
  end
end