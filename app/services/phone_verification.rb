class PhoneVerification

  attr_reader :user

  def initialize(options)
    @user = User.find(options[:user_id])
  end

  def process
    send_sms
  end

  def from
    # Add your twilio phone number (programmable phone number)
    Rails.application.secrets.twilio_phone_number
  end

  def to
    "+91#{user.phone_number}"
  end

  def body
    "Please enter this code '#{user.phone_verification_code}' to verify your phone number on application"
  end

  def twilio_client
    # Pass your twilio account SID and auth token
    @twilio ||= Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid,
                                         Rails.application.secrets.twilio_auth_token)
  end

  def send_sms
    Rails.logger.info "SMS: From: #{from} To: #{to} Body: \"#{body}\""

    twilio_client.messages.create(
      from: from,
      to: to,
      body: body
    )
  end
end