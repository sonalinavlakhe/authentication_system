class SessionsController < ApplicationController

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    
    return handle_invalid_login if @user.blank? || !@user.authenticate(params[:user][:password])
   
    if @user.unconfirmed?
      redirect_to new_confirmation_path(email: @user.email), alert: t(:email_not_verified_enter_again)
    elsif @user.phone_verified?
        login_user_and_redirect
    else
        send_sms_for_phone_verification_and_redirect
    end      
  end

  def new
  end

  def destroy
    forget(current_user)
    logout
    redirect_to root_path, notice: t(:logout_successfully)
  end

  private

  def send_sms_for_phone_verification(id)
    PhoneVerificationService.new(user_id: id).process
  end

  def handle_invalid_login
    flash.now[:alert] = t(:incorrect_email_or_password)
    render :new, status: :unprocessable_entity
  end

  def login_user_and_redirect
    login @user
    remember(@user) if params[:user][:remember_me] == "1"
    redirect_to root_path, notice: t(:login_successfully)
  end

  def send_sms_for_phone_verification_and_redirect
    send_sms_for_phone_verification(@user.id)
    redirect_to new_phone_verification_path(email: @user.email, remember_me: params[:user][:remember_me]), notice: t(:enter_verification_code_sent, phone_number: @user.phone_number)
  end
end
