class ConfirmationsController < ApplicationController
  
  def create
    @user = User.find_by(email: params[:email].downcase)
    if @user.present? && @user.unconfirmed?
      @user.send_confirmation_email!
      redirect_to root_path, notice: t(:check_confirmation_instruction_sent_on_email)
    else
      @user = nil
      redirect_to new_confirmation_path(email: params[:email]), alert: t(:user_not_present_or_confirmed)
    end
  end

  def edit
    verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
    user_id = verifier.verify(params[:confirmation_token])[:id]
    @user = User.find_by(id: user_id)
    if @user.present?
      @user.confirm!
      redirect_to root_path, notice: t(:account_confirmed)
    else
      redirect_to new_confirmation_path, alert: t(:invalid_token)
    end

    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_confirmation_path, alert: t(:invalid_token)
  end

  def new
    @user = User.find_by(email: params[:email])
  end
end
