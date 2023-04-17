class ConfirmationsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:create, :new]
  
  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user.present? && @user.unconfirmed?
      @user.send_confirmation_email!
      redirect_to root_path, notice: "Check your email for confirmation instructions."
    else
      redirect_to new_confirmation_path, alert: "We could not find a user with that email or that email has already been confirmed."
    end
  end

  def edit
    verifier = Rails.application.message_verifier(Rails.application.secret_key_base)
    user_id = verifier.verify(params[:confirmation_token])[:id]
    @user = User.find_by(id: user_id)
    if @user.present?
      @user.confirm!
      redirect_to root_path, notice: "Your account has been confirmed."
    else
      redirect_to new_confirmation_path, alert: "Invalid token."
    end
  end

  def new
    @user = User.new
  end
end
