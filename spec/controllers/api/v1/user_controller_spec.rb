require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe "POST #create" do
    context "successful creation" do
      it "creates JWT tokens"  do
        post :create, params: { username: "User1", email: "user1@gmail.com", password: "Password1", password_confirmation: "Password1", terms: 1 }
        expect(User.count).to eq(1)
        expect(response).to redirect_to(web_login_path)
        expect(response.cookies["jwt"]).to be_present
        expect(response.cookies["refresh_jwt"]).to be_present
      end

      it "sends a verification email" do
        expect {
          post :create, params: {
            username: "User1",
            email: "user1@gmail.com",
            password: "Password1",
            password_confirmation: "Password1",
            terms: 1
          }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq(["user1@gmail.com"])
        expect(mail.subject).to eq("Verify your email") # adjust to your actual subject
      end
    end

    context "unsuccessful creation" do
      it "redirects to register page and alert"  do
        post :create, params: { username: "User1", email: "user1@gmail.com", password: "Password2", password_confirmation: "Password1", terms: 1 }
        expect(response).to redirect_to(web_register_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET #verify" do
    let(:unverified_user) { create(:user, :unverified) }
    context "successful verification" do
      it "updates email_verified and clears verification_token" do
        get :verify, params: {token: unverified_user.verification_token}
        unverified_user.reload
        expect(unverified_user.email_verified).to be true
        expect(unverified_user.verification_token).to be_nil
        expect(flash[:notice]).to eq("Email verified successfully!")
        expect(response).to redirect_to(blog_posts_path)
      end
    end
    context "unsuccessful verification" do
      it "redirects  to login path and alert" do
        get :verify, params: {token: "wrongtoken"}
        unverified_user.reload
        expect(flash[:alert]).to include("Invalid or expired verification link.")
        expect(response).to redirect_to(web_login_path)
      end
    end
  end
end