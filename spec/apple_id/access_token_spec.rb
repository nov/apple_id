RSpec.describe AppleID::AccessToken do
  subject { access_token }
  let(:access_token) { AppleID::AccessToken.new(bearer_token) }
  let(:bearer_token) { 'bearer_token' }

  its(:access_token) { should == bearer_token }
  its(:id_token) { should == nil }

  context 'when refresh_token is given' do
    let(:access_token) do
      AppleID::AccessToken.new(
        bearer_token,
        refresh_token: 'refresh_token'
      )
    end
    let(:refresh_token) { 'refresh_token' }
    its(:refresh_token) { should == refresh_token }
  end

  context 'when id_token is given' do
    let(:access_token) do
      AppleID::AccessToken.new(
        bearer_token,
        id_token: id_token
      )
    end
    let(:id_token) do
      'eyJraWQiOiJBSURPUEsxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoianAueWF1dGguc2lnbmluLnNlcnZpY2UyIiwiZXhwIjoxNTU5NzA5ODkwLCJpYXQiOjE1NTk3MDkyOTAsInN1YiI6IjAwMDcyMy4yNWRhOGJlMzMyOTY0OTkxODk4NjMwOTQ3MjAyZmVmMC4wNDAyIiwiYXRfaGFzaCI6InpqUmlUN2QzVHFRNVM3cEZkbzZxWGcifQ.jDV-AVFM-Yx_lxc-hsJNF2mgD2PoRlQ8SJjharKom87pIKR1frQfaY_apO-AxyDrhvB3qOdfhZql08EHBHNWATlX3l6sAKL-bUPH6bzHxIZTWHZ9IOimPyvTOJNFyJWLsm6lGcqemKB1UQG2MQ06lI9qc6C6T8_obv2HPJ-Sm8OBE9z-CDyKGcFZ-R8b2Ut6TibmRyQ-kmB7na6ay9kGXm56I_TeA2QCMJGKH_X8C2M7kBPsO_WrYuogA3tnWLT8wi0TPD5zKnnBH0bXLgjeyE2lYRgboQttX6WqTdR0dN-mLi8ShTPEGUCkC7_jFJH9XpC7LfCeKl9tD3qzC_Dx1Q'
    end
    its(:id_token) { should be_a AppleID::IdToken }
  end
end
