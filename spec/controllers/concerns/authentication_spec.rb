require 'rails_helper'

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication
  end

  let(:user) { create(:user) }

  describe '#login' do
    it 'resets the session and sets the current user id' do
      session[:current_user_id] = nil
      controller.login(user)
      expect(session[:current_user_id]).to eq(user.id)
    end
  end

  describe '#logout' do
    it 'resets the session' do
      session[:current_user_id] = user.id
      controller.logout
      expect(session[:current_user_id]).to be_nil
    end
  end
end