require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_params) { attributes_for(:user) }

      it 'creates a new user' do
        expect {
          post :create, params: { user: valid_params }
        }.to change(User, :count).by(1)
      end

      it 'sends a confirmation email' do
        expect_any_instance_of(User).to receive(:send_confirmation_email!)
        post :create, params: { user: valid_params }
      end

      it 'redirects to the root path' do
        post :create, params: { user: valid_params }
        expect(response).to redirect_to(root_path)
      end

      it 'sets a notice flash message' do
        post :create, params: { user: valid_params }
        expect(flash[:notice]).to eq(t(:check_confirmation_instruction_sent_on_email))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { attributes_for(:user, password_confirmation: 'wrong_password') }

      it 'does not create a new user' do
        expect {
          post :create, params: { user: invalid_params }
        }.not_to change(User, :count)
      end

      it 'redirects to the sign up path' do
        post :create, params: { user: invalid_params }
        expect(response).to redirect_to(sign_up_path)
      end

      it 'sets a danger flash message' do
        post :create, params: { user: invalid_params }
        expect(flash[:danger]).not_to be_empty
      end
    end
  end
end