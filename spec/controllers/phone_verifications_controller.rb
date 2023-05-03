require 'rails_helper'
RSpec.describe PhoneVerificationsController, type: :controller do
 describe "GET #new" do
    let(:user) { create(:user) }

    it "assigns a user object with the given email" do
      get :new, params: {email: user.email, remember_me: "1"}

      expect(assigns(:user)).to eq(user)
    end
  end

  describe "POST #create" do
    let(:user) { create(:user, phone_verification_code: "123456") }

    before do
      User.skip_callback(:create, :before, :set_phone_attributes)
    end

    after do
      User.set_callback(:create, :before, :set_phone_attributes)
    end

    context "when the verification code is correct" do
      it "marks the phone as verified" do
        post :create, params: { user: { email: user.email, verification_code: "123456" } }
        expect(user.reload.phone_verified?).to be_truthy
      end
    end

    context "with invalid verification code" do
      it "redirects to the new phone verification page with a notice" do
        post :create, params: { user: { email: user.email, verification_code: "654321", remember_me: "0" } }
        expect(user.reload.phone_verified?).to eq(false)
        expect(response).to redirect_to(new_phone_verification_path(email: user.email, remember_me: "0"))
        expect(flash[:alert]).to eq(I18n.t(:invalid_code_enter_again))
      end
    end
  end

  describe "POST #resend_code" do
    let(:user) { create(:user, phone_number: "9860262304") }

    before do
      allow_any_instance_of(PhoneVerificationService).to receive(:process)
    end

    it "finds the user and generates a new verification code" do
      expect(User).to receive(:find_by).with(email: user.email).and_return(user)
      expect(PhoneVerificationService).to receive(:new).with(user_id: user.id).and_call_original
      expect_any_instance_of(PhoneVerificationService).to receive(:process)
      post :resend_code, params: { email: user.email, remember_me: "0" }
    end

    it "redirects to the new phone verification page with a notice" do   
      post :resend_code, params: { email: user.email, remember_me: "1" }
      expect(response).to redirect_to(new_phone_verification_path(email: user.email, remember_me: "1"))
      expect(flash[:notice]).to eq(I18n.t(:enter_verification_code_sent, phone_number: user.phone_number))
    end
  end
end