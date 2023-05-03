class PhoneVerificationsController < ApplicationController

  def new
    @user = User.find_by(email: params[:email])
    @remember_me = params[:remember_me]
  end

  def create
    @user = User.find_by(email: params[:user][:email])
    if @user.phone_verification_code == params[:user][:verification_code]
      @user.mark_phone_as_verified!
      login @user
      remember(@user) if params[:user][:remember_me] == "1"
      redirect_to root_path, notice: t(:login_successfully)
    else
      redirect_to new_phone_verification_path(email: @user.email, remember_me: params[:user][:remember_me]), alert: t(:invalid_code_enter_again)
    end
  end

  def resend_code
    @user = User.find_by(email: params[:email])
    PhoneVerificationService.new(user_id: @user.id).process
    redirect_to new_phone_verification_path(email: @user.email, remember_me: params[:remember_me]), notice: t(:enter_verification_code_sent, phone_number: @user.phone_number)
  end

end
