class User < ApplicationRecord

  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes

  has_secure_password
  
  before_save :downcase_email

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP} ,presence: true, uniqueness: true
  validates :phone_number, presence: true, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
  

  MAILER_FROM_EMAIL = "no-reply@example.com"

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def confirm!
    update_column(confirmed_at: Time.current)
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
