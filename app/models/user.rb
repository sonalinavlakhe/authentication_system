class User < ApplicationRecord

  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes

  has_secure_password

  has_secure_token :remember_token
  
  before_save :downcase_email
  before_create :set_phone_attributes

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP} ,presence: true, uniqueness: true
  validates :phone_number, presence: true, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }, uniqueness: true
  

  MAILER_FROM_EMAIL = "sonalibhavsar977@gmail.com"

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end
  
  def confirm!
    update_column(:confirmed_at, Time.current)
  end

  def mark_phone_as_verified!
     update_column(:phone_verified, true)
     update_column(:phone_verification_code, nil)
  end

  def generate_password_reset_token
    verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
    signed_id = verifier.generate({id: self.id, purpose: :reset_password}, expires_in: PASSWORD_RESET_TOKEN_EXPIRATION)
    signed_id
  end

  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_now
  end

  def generate_confirmation_token
    verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
    signed_id = verifier.generate({id: self.id, purpose: :confirm_email}, expires_in: CONFIRMATION_TOKEN_EXPIRATION)
    signed_id
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_later
  end
  
  private

  def downcase_email
    self.email = email.downcase
  end

  def set_phone_attributes
    self.phone_verified = false
    self.phone_verification_code = generate_phone_verification_code
  end

  def generate_phone_verification_code
    begin
     verification_code = SecureRandom.hex(3)
    end while self.class.exists?(phone_verification_code: verification_code)

    verification_code
  end

end
