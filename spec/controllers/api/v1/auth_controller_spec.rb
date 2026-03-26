require 'rails_helper'

RSpec.describe Api::V1::AuthController, type: :controller do
  describe "POST #create" do
    let(:user) { create(:user) }

    context "with valid credentials" do
      it "creates a valid user" do
        user = build(:user)
        expect(user).to be_valid
      end
      
      it "sets JWT cookies and redirects to blog_posts_path" do
        post :create, params: { email: user.email, password: "Password1" }

        expect(flash[:notice]).to eq("Welcome back!")
        expect(response).to redirect_to(blog_posts_path)
        expect(cookies.signed[:jwt]).to be_present
        expect(cookies.signed[:refresh_jwt]).to be_present
      end
    end

    context "with invalid credentials" do
      it "renders login with alert" do
        post :create, params: { email: user.email, password: "wrong" }

        expect(response).to redirect_to(api_v1_login_path)
        expect(flash[:alert]).to eq("Invalid Credentials.")
      end
    end

    context "when email not verified" do
        let(:unverified_user) { create(:user, :unverified) }  # using the trait we made

        it "responds 403 status with alert" do
          puts unverified_user.email_verified  # add this temporarily
          post :create, params: { email: unverified_user.email, password: "Password1" }

          expect(flash[:alert]).to eq("Please verify your email before logging in.")
          expect(response).to redirect_to(api_v1_login_path)
        end
      end
    end

  describe "DELETE #logout" do
    let(:user) { create(:user) }

    before do
      # simulate logged in user
      access_token = JWT.encode(
        { user_id: user.id, exp: 10.minutes.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )
      refresh_token = JWT.encode(
          { user_id: user.id, exp: 7.days.from_now.to_i },
          Rails.application.secret_key_base, 'HS256'
      )
      cookies.signed[:jwt] = access_token
      cookies.signed[:refresh_jwt] = refresh_token
    end

    it "clears cookies and redirects to login" do
      delete :logout

      expect(response.cookies["jwt"]).to be_nil
      expect(response.cookies["refresh_jwt"]).to be_nil
      expect(response).to redirect_to(api_v1_login_path)
    end
  end
end