RSpec.describe AppleID::EventToken::Event do
  subject { event }
  let(:event) do
    AppleID::EventToken::Event.new attributes
  end
  let(:required_attributes) do
    {
      type: type,
      sub: SecureRandom.uuid,
      event_time: Time.now.to_i
    }
  end
  let(:attributes) { required_attributes }

  context 'when email & is_private_email is given' do
    let(:type) { 'email-enabled' }
    let(:email) { "#{SecureRandom.hex(8)}@privaterelay.appleid.com" }
    let(:is_private_email) { 'true' }
    let(:attributes) do
      required_attributes.merge(
        email: email,
        is_private_email: is_private_email
      )
    end
    its(:email) { should == email }

    context 'when is_private_email == true' do
      let(:is_private_email) { true }
      its(:is_private_email) { should == true }
      its(:is_private_email?) { should be_truthy }
    end

    context 'when is_private_email == false' do
      let(:is_private_email) { false }
      its(:is_private_email) { should == false }
      its(:is_private_email?) { should be_falsy }
    end

    context 'when is_private_email == "true"' do
      let(:is_private_email) { 'true' }
      its(:is_private_email) { should == 'true' }
      its(:is_private_email?) { should be_truthy }
    end

    context 'when is_private_email == "false"' do
      let(:is_private_email) { 'false' }
      its(:is_private_email) { should == 'false' }
      its(:is_private_email?) { should be_falsy }
    end
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