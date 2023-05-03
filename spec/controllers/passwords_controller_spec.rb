require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let(:user) { create(:user, email: "test@example.com", confirmed_at: Time.current) }

  describe "GET #new" do
    it "assigns the current user" do
      session[:current_user_id] = user.id
      get :new
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, confirmed_at: nil) }
    let(:params) { { user: { email: user.email } } }

    context 'when user is present but not confirmed' do
      before do
        post :create, params: params
      end

      it 'redirects to the new confirmation path' do
        expect(response).to redirect_to(new_confirmation_path)
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq(I18n.t(:check_confirmation_instruction_sent_on_email))
      end

      it 'does not send password reset email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end

  describe "GET #edit" do
    let(:user) { create(:user, email: "test@example.com", confirmed_at: Time.current) }

    context "with a valid reset token" do
      let(:token) { Rails.application.message_verifier(Rails.application.secret_key_base).generate({id: user.id, purpose: :reset_password}) }

      before do
        get :edit, params: { password_reset_token: token }
      end

      it "finds the correct user" do
        expect(assigns(:user)).to eq(user)
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "with an invalid reset token" do
      before do
        get :edit, params: { password_reset_token: "invalid_token" }
      end

      it "redirects to the new password path" do
        expect(response).to redirect_to(new_password_path)
      end

      it "sets an alert message" do
        expect(flash[:alert]).to eq(I18n.t(:invalid_token))
      end
    end

    context "when the user is unconfirmed" do
      let(:token) { Rails.application.message_verifier(Rails.application.secret_key_base).generate({id: user.id, purpose: :reset_password }) }
      before do
        user.update(confirmed_at: nil)
        get :edit, params: { password_reset_token: token }
      end

      it "redirects to the new confirmation path" do
        expect(response).to redirect_to(new_confirmation_path)
      end

      it "sets an alert message" do
        expect(flash[:alert]).to eq(I18n.t(:check_confirmation_instruction_sent_on_email))
      end
    end
  end

  describe "PUT #update" do
    let(:user) { create(:user) }
    let(:password_reset_token) { "reset-token"}

    before do
      allow(controller).to receive(:decrypt_reset_token).and_return(user.id)
      allow(controller).to receive(:params).and_return({ password_reset_token: password_reset_token })
    end

    context "when user is not found" do
      before { allow(User).to receive(:find_by).and_return(nil) }

      it "redirect to new with error message" do
        put :update, params: { password_reset_token: "reset-token" }
        expect(response).to redirect_to(new_confirmation_path)
        expect(flash[:alert]).to eq(I18n.t(:invalid_token))
      end
    end

    context "when user is found" do
      before { allow(User).to receive(:find_by).and_return(user) }

      context "when user is unconfirmed" do
        before { allow(user).to receive(:unconfirmed?).and_return(true) }

        it "redirects to new confirmation page with error message" do
          put :update, params: { password_reset_token: "reset-token" }
          expect(response).to redirect_to(new_confirmation_path)
          expect(flash[:alert]).to eq(I18n.t(:check_confirmation_instruction_sent_on_email))
        end
      end
    end

    context "when password_reset_token is invalid" do
      before { allow(controller).to receive(:decrypt_reset_token).and_raise(ActiveSupport::MessageVerifier::InvalidSignature) }

      it "redirects to new password page with error message" do
        patch :update, params: { password_reset_token: "reset-token" }
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq(I18n.t(:invalid_token))
      end
    end
  end
end