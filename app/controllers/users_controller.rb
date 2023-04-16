class UsersController < ApplicationController
  before_action :redirect_if_authenticated, only: [:create, :new]
  
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_confirmation_email!
      redirect_to root_path, notice: "Please check your email for confirmation instructions."
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
