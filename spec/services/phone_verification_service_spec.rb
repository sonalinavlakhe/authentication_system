require 'rails_helper'

RSpec.describe PhoneVerificationService do
  let(:user) { create(:user, phone_number: '1234567890', phone_verification_code: '1234') }
  let(:service) { PhoneVerificationService.new(user_id: user.id) }

  describe '#process' do
    it 'sends an SMS with the verification code to the user phone number' do
      expect(service).to receive(:send_sms)

      service.process
    end
  end

  describe '#from' do
    it 'returns the twilio phone number from secrets' do
      expect(service.from).to eq(Rails.application.secrets.twilio_phone_number)
    end
  end

  describe '#to' do
    it 'returns the user phone number with country code' do
      expect(service.to).to eq("+91#{user.phone_number}")
    end
  end

  describe '#body' do
    it 'returns the SMS body with user verification code' do
      expect(service.body).to eq("Please enter this code '#{user.phone_verification_code}' to verify your phone number on application")
    end
  end

  describe '#twilio_client' do
    it 'returns a Twilio REST client with secrets credentials' do
      expect(service.twilio_client).to be_a(Twilio::REST::Client)
      expect(service.twilio_client.account_sid).to eq(Rails.application.secrets.twilio_account_sid)
      expect(service.twilio_client.auth_token).to eq(Rails.application.secrets.twilio_auth_token)
    end
  end

  describe '#send_sms' do
    it 'sends an SMS to the user phone number using twilio client' do
      expect(service.twilio_client.messages).to receive(:create).with(
        from: service.from,
        to: service.to,
        body: service.body
      )

      service.send_sms
    end
  end
end