RSpec.describe AppleID::IdToken::RealUserStatus do
  subject { status }
  let(:status) { AppleID::IdToken::RealUserStatus.new(value) }

  context 'when value is 0' do
    let(:value)        { 0 }
    its(:status)       { should == :unsupported }
    its(:unsupported?) { should == true }
    its(:unknown?)     { should == false }
    its(:likely_real?) { should == false }
  end

  context 'when value is 1' do
    let(:value)        { 1 }
    its(:status)       { should == :unknown }
    its(:unsupported?) { should == false }
    its(:unknown?)     { should == true }
    its(:likely_real?) { should == false }
  end

  context 'when value is 2' do
    let(:value)        { 2 }
    its(:status)       { should == :likely_real }
    its(:unsupported?) { should == false }
    its(:unknown?)     { should == false }
    its(:likely_real?) { should == true }
  end

  context 'when value is 3' do
    let(:value)        { 3 }
    [:status, :unsupported?, :unknown?, :likely_real?].each do |method|
      describe method do
        it do
          expect do
            subject.send(method)
          end.to raise_error AppleID::IdToken::RealUserStatus::UndefinedStatus
        end
      end
    end
  end
end
