class PhoneVerificationsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(phone_verification_code: params[:code])
    if @user
      params
      @user.mark_phone_as_verified!
      login @user
      remember(@user) if params[:user][:remember_me] == "1"
      redirect_to root_path, notice: "You have successfully logged in."
    else
      flash.now[:alert] = "Mobile verification is pending due to Invalid verification code try to enter again"
      render :new, status: :unprocessable_entity
    end
  end


end
