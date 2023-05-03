class UsersController < ApplicationController
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_confirmation_email!
      redirect_to root_path, notice: t(:check_confirmation_instruction_sent_on_email)
    else
      redirect_to sign_up_path, danger: @user.errors.full_messages.join(", ")
    end
  end

  def new
    @user = User.new
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :phone_number)
  end 
end
