class User < ApplicationRecord

  has_secure_password
  
  before_save :downcase_email

  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP} ,presence: true, uniqueness: true

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

  private

  def downcase_email
    self.email = email.downcase
  end
end
