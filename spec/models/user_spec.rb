require 'rails_helper'

RSpec.describe User, type: :model do
  let(:auth_response) {
    {
      uid: 'some-uid',
      provider: 'github',
      info: {
        email: 'a@b.com'
      },
      credentials: {
        token: 'some-random-secret-token'
      }
    }
  }

  before do
    @double = double
    @double.stub(:uid).and_return(auth_response[:uid])
    @double.stub(:provider).and_return(auth_response[:provider])
    @double2 = double
    @double2.stub(:email).and_return(auth_response[:info][:email])
    @double2.stub(:token).and_return(auth_response[:credentials][:token])
    @double.stub(:info).and_return(@double2)
    @double.stub(:credentials).and_return(@double2)
  end

  describe ".from_omniauth" do
    context "when this is the first time for the user to authenticate with GitHub in this app" do
      it "should create the user and save all its data based on OAUTH auth_response" do
        expect{
          User.from_omniauth(@double)
        }.to change(User, :count).by(1)
      end

      it "should assign all user data from the OAUTH response data" do
        user = User.from_omniauth(@double)
        expect(user.uid).to eq(auth_response[:uid])
        expect(user.provider).to eq(auth_response[:provider])
        expect(user.email).to eq(auth_response[:info][:email])
        expect(user.encrypted_password).to eq(auth_response[:credentials][:token])
      end
    end

    context "when this is NOT the first time for the user to authenticate with GitHub in this app" do
      before do
        @double3 = double
        @double3.stub(:uid).and_return(auth_response[:uid])
        @double3.stub(:provider).and_return(auth_response[:provider])
        @double4 = double
        @double4.stub(:email).and_return(auth_response[:info][:email])
        @double4.stub(:token).and_return('new-token')
        @double3.stub(:info).and_return(@double4)
        @double3.stub(:credentials).and_return(@double4)

        @user1 = User.from_omniauth(@double)
      end

      it "should not create the user" do
        expect{
          User.from_omniauth(@double3)
        }.to change(User, :count).by(0)
      end

      it "should only update its encrypted_password value" do
        user2 = User.from_omniauth(@double3)
        expect(user2.encrypted_password).to_not eq(@user1.encrypted_password)
        expect(user2.encrypted_password).to eq('new-token')
      end
    end

  end

end
