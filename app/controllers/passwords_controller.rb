class PasswordsController < ApplicationController

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user.blank?
      redirect_to new_password_path, alert: t(:user_not_present)
    elsif @user.confirmed?
      send_password_reset_email_and_redirect_to_root_path
    else
      redirect_to new_confirmation_path, alert: t(:check_confirmation_instruction_sent_on_email)
    end
    
  end

  def update
    user_id = decrypt_reset_token(params[:password_reset_token])
    @user = User.find_by(id: user_id)
    
    if @user.blank?
      redirect_to new_confirmation_path, alert: t(:invalid_token)
    elsif @user.unconfirmed?
      redirect_to new_confirmation_path, alert: t(:check_confirmation_instruction_sent_on_email)
    elsif @user.update(password_params)
      redirect_to login_path, notice: t(:password_updated_successfully)
    else      
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity  
    end

    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t(:invalid_token)
  end
  
  def edit
    user_id = decrypt_reset_token(params[:password_reset_token])
    @user = User.find_by(id: user_id)
    
    redirect_to new_password_path, alert: t(:invalid_token)if @user.nil?
    
    if @user.present? && @user.unconfirmed?
      redirect_to new_confirmation_path, alert: t(:check_confirmation_instruction_sent_on_email)
    end

    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t(:invalid_token)
  end

  def new
    @user = current_user
  end


  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def send_password_reset_email_and_redirect_to_root_path
    @user.send_password_reset_email!
    redirect_to root_path, notice: t(:reset_password_confirmation_instruction_sent)
  end

  def decrypt_reset_token(password_reset_token)
    verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
    user_id = verifier.verify(password_reset_token)[:id]
  end
end
