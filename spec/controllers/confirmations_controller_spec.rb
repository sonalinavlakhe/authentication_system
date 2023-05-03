require 'rails_helper'
RSpec.describe ConfirmationsController, type: :controller do
  let(:user) { create(:user, email: 'test@example.com', confirmed_at: nil) }


  describe 'POST #create' do
    context 'when user is present and unconfirmed' do
      it 'sends a confirmation email' do
        expect { post :create, params: { email: user.email } }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'redirects to the root path with a notice' do
        post :create, params: { email: user.email }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t(:check_confirmation_instruction_sent_on_email))
      end
    end

    context 'when user is not present or already confirmed' do
      it 'redirects to the new confirmation path with an alert' do
        post :create, params: { email: 'invalid@example.com' }
        expect(response).to redirect_to(new_confirmation_path(email: 'invalid@example.com'))
        expect(flash[:alert]).to eq(I18n.t(:user_not_present_or_confirmed))
      end
    end
  end

  describe 'GET #edit' do
    context 'when confirmation token is valid' do
      it 'confirms the user' do
        token = Rails.application.message_verifier(Rails.application.secret_key_base).generate(id: user.id)
        get :edit, params: { confirmation_token: token }
        expect(user.reload.confirmed?).to be(true)
      end

      it 'redirects to the root path with a notice' do
        token = Rails.application.message_verifier(Rails.application.secret_key_base).generate(id: user.id)
        get :edit, params: { confirmation_token: token }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t(:account_confirmed))
      end
    end
    context 'when confirmation token is invalid' do
      it 'redirects to the new confirmation path with an alert' do
        get :edit, params: { confirmation_token: 'invalid_token' }
        expect(response).to redirect_to(new_confirmation_path)
        expect(flash[:alert]).to eq(I18n.t(:invalid_token))
      end
    end
  end

  describe 'GET #new' do
    it 'finds the user by email' do
      get :new, params: { email: user.email }
      expect(assigns(:user)).to eq(user)
    end
  end
end