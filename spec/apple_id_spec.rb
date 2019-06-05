RSpec.describe AppleID do
  its(:version) do
    AppleID::VERSION.should_not be_blank
  end

  describe 'debugging feature' do
    after { AppleID.debugging = false }

    its(:logger) { should be_a Logger }
    its(:debugging?) { should == false }

    describe '.debug!' do
      before { AppleID.debug! }
      its(:debugging?) { should == true }
    end

    describe '.debug' do
      it 'should enable debugging within given block' do
        AppleID.debug do
          Rack::OAuth2.debugging?.should == true
          OpenIDConnect.debugging?.should == true
          AppleID.debugging?.should == true
        end
        Rack::OAuth2.debugging?.should == false
        OpenIDConnect.debugging?.should == false
        AppleID.debugging?.should == false
      end

      it 'should not force disable debugging' do
        Rack::OAuth2.debug!
        OpenIDConnect.debug!
        AppleID.debug!
        AppleID.debug do
          Rack::OAuth2.debugging?.should == true
          OpenIDConnect.debugging?.should == true
          AppleID.debugging?.should == true
        end
        Rack::OAuth2.debugging?.should == true
        OpenIDConnect.debugging?.should == true
        AppleID.debugging?.should == true
      end
    end
  end
end
