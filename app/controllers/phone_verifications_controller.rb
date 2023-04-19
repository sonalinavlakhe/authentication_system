class PhoneVerificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
  end

  def create
    @user = User.find_by(phone_verification_code: params[:code])

    if @user
      @user.mark_phone_as_verified!
      redirect_to root_path, notice: "You have successfully logged in."
    else
      flash.now[:alert] = "Mobile verication is pending due to Invalid verification code."
      render :new, status: :unprocessable_entity
    end
  end

end
