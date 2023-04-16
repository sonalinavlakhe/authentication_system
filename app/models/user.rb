class User < ApplicationRecord

  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes

  has_secure_password
  
  before_save :downcase_email

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP} ,presence: true, uniqueness: true
  validates :phone_number, presence: true, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }, uniqueness: true
  

  MAILER_FROM_EMAIL = "sonalibhavsar977@gmail.com"

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  def generate_confirmation_token
    verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
    signed_id = verifier.generate({id: self.id, purpose: :confirm_email}, expires_in: CONFIRMATION_TOKEN_EXPIRATION)

    signed_id
  end

  def confirm!
    update_column(:confirmed_at, Time.current)
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
