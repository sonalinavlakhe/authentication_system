class PasswordsController < ApplicationController

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user.present?
      if @user.confirmed?
        @user.send_password_reset_email!
        redirect_to root_path, notice: "Plese follow instructions to reset password in email."
      else
        redirect_to new_confirmation_path, alert: "Please confirm your email first."
      end
    else
      redirect_to new_password_path, alert: "User not exists with this email id"
    end
  end

  def update
    begin
      verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
      user_id = verifier.verify(params[:password_reset_token])[:id]
      @user = User.find_by(id: user_id)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Invalid or expired token."
      return
    end

    if @user.present?
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: "You must confirm your email before you can sign in."
      elsif @user.update(password_params)
        redirect_to login_path, notice: "Sign in with new updated password"
        return
      else      
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity  
      end
    else
      flash.now[:alert] = "Invalid or expired token."
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    begin
      verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
      user_id = verifier.verify(params[:password_reset_token])[:id]
      @user = User.find_by(id: user_id)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Invalid or expired token."
      return
    end

    if @user.present? && @user.unconfirmed?
      redirect_to new_confirmation_path, alert: "You must confirm your email before you can sign in."
    elsif @user.nil?
      redirect_to new_password_path, alert: "Invalid or expired token."
    end
  end

  def new
  end


  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
