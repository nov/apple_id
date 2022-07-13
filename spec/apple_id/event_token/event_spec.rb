RSpec.describe AppleID::EventToken::Event do
  subject { event }
  let(:event) do
    AppleID::EventToken::Event.new(
      type: type,
      sub: SecureRandom.uuid,
      event_time: Time.now.to_i
    )
  end

  context 'when type=email-enabled' do
    let(:type) { 'email-enabled' }
    its(:type) { should == AppleID::EventToken::Event::Type::EMAIL_ENABLED }
    its(:email_enabled?) { should be_truthy }
  end

  context 'when type=email-disabled' do
    let(:type) { 'email-disabled' }
    its(:type) { should == AppleID::EventToken::Event::Type::EMAIL_DISABLED }
    its(:email_disabled?) { should be_truthy }
  end

  context 'when type=consent-revoked' do
    let(:type) { 'consent-revoked' }
    its(:type) { should == AppleID::EventToken::Event::Type::CONSENT_REVOKED }
    its(:consent_revoked?) { should be_truthy }
  end

  context 'when type=account-delete' do
    let(:type) { 'account-delete' }
    its(:type) { should == AppleID::EventToken::Event::Type::ACCOUNT_DELETED }
    its(:account_deleted?) { should be_truthy }
    its(:account_delete?) { should be_truthy }
  end
end