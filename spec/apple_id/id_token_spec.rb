RSpec.describe AppleID::IdToken do
  subject { id_token }
  let(:signature_base_string) do
    'eyJraWQiOiJBSURPUEsxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoianAueWF1dGguc2lnbmluLnNlcnZpY2UyIiwiZXhwIjoxNTU5NzA5ODkwLCJpYXQiOjE1NTk3MDkyOTAsInN1YiI6IjAwMDcyMy4yNWRhOGJlMzMyOTY0OTkxODk4NjMwOTQ3MjAyZmVmMC4wNDAyIiwiYXRfaGFzaCI6InpqUmlUN2QzVHFRNVM3cEZkbzZxWGcifQ'
  end
  let(:signature) do
    'jDV-AVFM-Yx_lxc-hsJNF2mgD2PoRlQ8SJjharKom87pIKR1frQfaY_apO-AxyDrhvB3qOdfhZql08EHBHNWATlX3l6sAKL-bUPH6bzHxIZTWHZ9IOimPyvTOJNFyJWLsm6lGcqemKB1UQG2MQ06lI9qc6C6T8_obv2HPJ-Sm8OBE9z-CDyKGcFZ-R8b2Ut6TibmRyQ-kmB7na6ay9kGXm56I_TeA2QCMJGKH_X8C2M7kBPsO_WrYuogA3tnWLT8wi0TPD5zKnnBH0bXLgjeyE2lYRgboQttX6WqTdR0dN-mLi8ShTPEGUCkC7_jFJH9XpC7LfCeKl9tD3qzC_Dx1Q'
  end
  let(:invalid_signature) do
    Base64.urlsafe_encode64('invalid', padding: false)
  end
  let(:id_token_str) do
    [signature_base_string, signature].join('.')
  end
  let(:id_token) { AppleID::IdToken.decode(id_token_str) }

  its(:original_jwt) { should be_a JSON::JWS }

  describe '.decode' do
    it { should be_a AppleID::IdToken }

    context 'when signature invalid' do
      let(:id_token_str) do
        [signature_base_string, invalid_signature].join('.')
      end

      it do
        expect do
          AppleID::IdToken.decode(id_token_str)
        end.not_to raise_error
      end

      it { should be_a AppleID::IdToken }
    end
  end

  describe '#verify!' do
    let(:expected_client) do
      AppleID::Client.new(
        identifier: 'jp.yauth.signin.service2',
        team_id: 'team_id',
        key_id: 'key_id',
        private_key: OpenSSL::PKey::EC.generate('prime256v1')
      )
    end
    let(:unexpected_client) do
      AppleID::Client.new(
        identifier: 'client_id',
        team_id: 'team_id',
        key_id: 'key_id',
        private_key: OpenSSL::PKey::EC.generate('prime256v1')
      )
    end

    context 'when no expected claims given' do
      it do
        expect do
          mock_json :get, AppleID::JWKS_URI, 'jwks' do
            travel_to(Time.at id_token.iat) do
              id_token.verify!
            end
          end
        end.not_to raise_error
      end
    end

    context 'when claims are valid' do
      it do
        expect do
          travel_to(Time.at id_token.iat) do
            id_token.verify! client: expected_client, verify_signature: false
          end
        end.not_to raise_error
      end
    end

    context 'when claims are invalid' do
      it do
        expect do
          travel_to(Time.at id_token.iat) do
            id_token.verify!(
              client: unexpected_client,
              nonce: 'invalid',
              state: 'invalid',
              access_token: 'invalid',
              code: 'invalid',
              verify_signature: false
            )
          end
        end.to raise_error AppleID::IdToken::VerificationFailed, 'Claims Verification Failed at [:aud, :nonce, :s_hash, :at_hash, :c_hash]'
      end

      context 'when future token given' do
        it do
          expect do
            travel_to(Time.at id_token.iat - 1) do
              id_token.verify!(
                verify_signature: false
              )
            end
          end.to raise_error AppleID::IdToken::VerificationFailed, 'Claims Verification Failed at [:iat]'
        end
      end

      context 'when expired token given' do
        it do
          expect do
            id_token.verify!(
              verify_signature: false
            )
          end.to raise_error AppleID::IdToken::VerificationFailed, 'Claims Verification Failed at [:exp]'
        end
      end
    end

    context 'when signature is invalid' do
      let(:id_token_str) do
        [signature_base_string, invalid_signature].join('.')
      end

      context 'when verify_signature=false is given' do
        it do
          expect do
            travel_to(Time.at id_token.iat) do
              id_token.verify! client: expected_client, verify_signature: false
            end
          end.not_to raise_error
        end
      end

      context 'otherwise' do
        it do
          expect do
            mock_json :get, AppleID::JWKS_URI, 'jwks' do
              travel_to(Time.at id_token.iat) do
                id_token.verify! client: expected_client
              end
            end
          end.to raise_error AppleID::IdToken::VerificationFailed, 'Signature Verification Failed'
        end
      end
    end
  end
end
