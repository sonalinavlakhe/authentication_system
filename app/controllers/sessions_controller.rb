class SessionsController < ApplicationController

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: " email is not verified yet please confirm email by re-entering"
      elsif @user.authenticate(params[:user][:password])
        if @user.phone_verified?
          login @user
          remember(@user) if params[:user][:remember_me] == "1"
          redirect_to root_path, notice: "You have successfully logged in."
        else
          send_sms_for_phone_verification(@user.id)
          flash.now[:alert] = "Please enter the verification code we sent to your number #{@user.phone_number}."
          render 'phone_verifications/new', remember_me: params[:user][:remember_me], notice: "Please enter the verification code we sent to your number #{@user.phone_number}."
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


  private

  def send_sms_for_phone_verification(id)
    PhoneVerification.new(user_id: id).process
  end
end
