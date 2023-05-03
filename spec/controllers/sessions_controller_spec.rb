require 'rails_helper'
RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    let(:user) { create(:user, password: "password", password_confirmation: 'password') }
    let(:params) { { user: { email: user.email, password: "password" } } }

    context "when the user is valid" do
      context "when the user is unconfirmed" do
        before { user.update(confirmed_at: nil) }

        it "redirects to the new confirmation path with an alert message" do
          post :create, params: params

          expect(response).to redirect_to(new_confirmation_path(email: user.email))
          expect(flash[:alert]).to eq(I18n.t(:email_not_verified_enter_again))
        end
      end

      context "when the user is phone-verified" do
        before { user.update(phone_verified: true, confirmed_at: Time.now) }

        it "logs in the user and redirects to the root path" do
          post :create, params: params

          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t(:login_successfully))
          expect(session[:current_user_id]).to eq(user.id)
        end

        it "remembers the user if the remember_me parameter is set" do
          post :create, params: { user: params[:user].merge(remember_me: "1") }

          expect(response).to redirect_to(root_path)
          expect(cookies[:remember_token]).not_to be_nil
        end
      end

      context "when the user is not phone-verified" do
        before { user.update(phone_verified: false, confirmed_at: Time.now) }

        it "sends an SMS for phone verification and redirects to the new phone verification path" do
          expect_any_instance_of(PhoneVerificationService).to receive(:process)
          post :create, params: { user: params[:user].merge(remember_me: "1") }
          expect(response).to redirect_to(new_phone_verification_path(email: user.email, remember_me: "1"))
          expect(flash[:notice]).to eq(I18n.t(:enter_verification_code_sent, phone_number: user.phone_number))
        end
      end

      context "when the user is invalid" do
        let(:params) { { user: { email: "invalid@example.com", password: "password" } } }

        it "renders the new page with an error message" do
          post :create, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:new)
          expect(flash[:alert]).to eq(I18n.t(:incorrect_email_or_password))
        end
      end
    end
  end
end