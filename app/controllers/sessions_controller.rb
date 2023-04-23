class SessionsController < ApplicationController

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: " email is not confirmed yet confirm it by re-entering"
      elsif @user.authenticate(params[:user][:password])
        login @user
        remember(@user) if params[:user][:remember_me] == "1"
        if @user.phone_verified?
          redirect_to root_path, notice: "You have successfully logged in."
        else
          redirect_to new_phone_verification_path, notice: "Please enter the verification code we sent to your number #{@user.phone_number}."
        end
      else
        flash.now[:alert] = "Incorrect email or password."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Incorrect email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def new
  end

  def destroy
    forget(current_user)
    logout
    redirect_to root_path, notice: "You have successfully Signed out"
  end
end
