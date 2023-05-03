require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      email: 'user@example.com',
      password: 'password123',
      phone_number: '5551234567'
    }
  end

  describe 'validations' do
    subject { User.new(valid_attributes) }

      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email) }
      it { should validate_presence_of(:phone_number) }
      it { should validate_uniqueness_of(:phone_number).case_insensitive }
      it { should allow_value('user@example.com').for(:email) }
      it { should_not allow_value('user@example').for(:email) }
      it { should allow_value('1234567890').for(:phone_number) }
      it { should_not allow_value('12345678').for(:phone_number) }
  end

  describe 'callbacks' do
    it 'downcases the email before saving' do
      user = User.new(valid_attributes.merge(email: 'USER@example.com'))
      expect { user.save }.to change { user.email }.from('USER@example.com').to('user@example.com')
    end
 
  
    it 'sets phone_verified to false and generates a phone_verification_code before creating' do
      user = User.new(valid_attributes.merge(phone_verified: true, phone_verification_code: 'abc123'))
      expect { user.save }.to change { user.phone_verified }.from(true).to(false)
      expect(user.phone_verification_code).to be_present
    end 
  end

  describe '#confirmed?' do
    it 'returns true if confirmed_at is present' do
      user = User.new(valid_attributes.merge(confirmed_at: Time.current))
      expect(user.confirmed?).to eq(true)
    end

    it 'returns false if confirmed_at is nil' do
      user = User.new(valid_attributes.merge(confirmed_at: nil))
      expect(user.confirmed?).to eq(false)
    end
  end

  describe '#unconfirmed?' do
    it 'returns true if confirmed_at is nil' do
      user = User.new(valid_attributes.merge(confirmed_at: nil))
      expect(user.unconfirmed?).to eq(true)
    end

    it 'returns false if confirmed_at is present' do
      user = User.new(valid_attributes.merge(confirmed_at:Time.current))
      expect(user.unconfirmed?).to eq(false)
    end
  end

  describe '#confirm!' do
    it 'updates confirmed_at to the current time' do
      user = User.create(valid_attributes.merge(confirmed_at: nil))
      user.confirm!
      expect(user.confirmed_at).to be_present
    end
  end

  describe '#mark_phone_as_verified!' do
    it 'updates phone_verified to true and phone_verification_code to nil' do
      user = User.create(valid_attributes.merge(phone_verified: false, phone_verification_code: 'abc123'))
      user.mark_phone_as_verified!
      expect(user.phone_verified).to eq(true)
      expect(user.phone_verification_code).to be_nil
    end
  end

  describe '#generate_password_reset_token' do
    it 'generates a signed ID with the user ID and reset_password purpose' do
      user = User.create(valid_attributes)
      signed_id = user.generate_password_reset_token
      verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
      expect(verifier.valid_message?(signed_id)).to eq(true)
      expect(verifier.verified(signed_id)).to eq({ id: user.id, purpose: :reset_password })
    end
  end

  describe '#send_password_reset_email!' do
    let(:user) { User.create(valid_attributes) }
    before do
      allow(user).to receive(:generate_password_reset_token).and_return("abc123")
      allow(UserMailer).to receive_message_chain(:password_reset, :deliver_now)
    end

    it "generates a password reset token" do
      expect(user).to receive(:generate_password_reset_token).and_return("abc123")
      user.send_password_reset_email!
    end

    it "sends a password reset email" do
      expect(UserMailer).to receive(:password_reset).with(user, "abc123").and_return(double("mailer", :deliver_now => nil))
      user.send_password_reset_email!
    end
  end

  describe '#generate_confirmation_token' do
    it 'generates a signed ID with the user ID and confirm_email purpose' do
      user = User.create(valid_attributes)
      signed_id = user.generate_confirmation_token
      verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
      expect(verifier.valid_message?(signed_id)).to eq(true)
      expect(verifier.verified(signed_id)).to eq({ id: user.id, purpose: :confirm_email })
    end
  end

  describe '#send_confirmation_email!' do
    let(:user) { User.create(valid_attributes) }
    before do
      allow(user).to receive(:generate_confirmation_token).and_return("abc123")
      allow(UserMailer).to receive_message_chain(:confirmation, :deliver_now)
    end

    it "generates a confirmation token" do
      expect(user).to receive(:generate_confirmation_token).and_return("abc123")
      user.send_confirmation_email!
    end

    it "sends a confirmation email" do
      expect(UserMailer).to receive(:confirmation).with(user, "abc123").and_return(double("mailer", :deliver_now => nil))
      user.send_confirmation_email!
    end
  end

  describe "private methods" do
    let(:user) { User.create(valid_attributes) }

    describe "#downcase_email" do
      it "downcases the email attribute" do
        user.email = "USER@EXAMPLE.COM"
        user.send(:downcase_email)
        expect(user.email).to eq("user@example.com")
      end
    end

    describe "#set_phone_attributes" do
      it "sets phone_verified to false" do
        user.send(:set_phone_attributes)
        expect(user.phone_verified).to eq(false)
      end

      it "generates a phone verification code" do
        expect(user).to receive(:generate_phone_verification_code).and_return("abc123")
        user.send(:set_phone_attributes)
        expect(user.phone_verification_code).to eq("abc123")
      end
    end
  end
end