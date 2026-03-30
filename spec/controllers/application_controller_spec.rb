require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render json: { message: "Success", user: current_user&.id }, status: :ok
    end
  end

  let(:user) { create(:user) }
  let(:valid_token) { JWT.encode({ user_id: user.id, exp: 1.hour.from_now.to_i }, ENV['JWT_SECRET_KEY'], 'HS256') }
  let(:expired_token) { JWT.encode({ user_id: user.id, exp: 1.minute.ago.to_i }, ENV['JWT_SECRET_KEY'], 'HS256') }

  describe "Authentication Middleware" do
    
    context "when no token is provided" do
      it "returns unauthorized for JSON requests" do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects to login for HTML requests" do
        get :index, format: :html
        expect(response).to redirect_to(web_login_path)
      end
    end

    context "with a valid JWT in headers (Mobile Style)" do
      before do
        request.headers['Authorization'] = "Bearer #{valid_token}"
      end

      it "allows access and sets @current_user" do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["user"]).to eq(user.id)
      end
    end

    context "with a valid JWT in signed cookies (Web Style)" do
      before do
        cookies.signed[:jwt] = valid_token
      end

      it "allows access and identifies the user" do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context "when token is expired" do
      let(:header) do
        token = request.headers['Authorization']
        token&.start_with?("Bearer ") ? token.split(" ").last : nil
      end

      before do
        request.headers['Authorization'] = "Bearer #{expired_token}"
      end

      it "returns unauthorized if no refresh token is present" do
        allow(controller).to receive(:get_refresh_token).and_return(nil)
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("No refresh token found")
      end
    end
  end

  describe "#current_user" do
    it "memoizes the user to avoid multiple database hits" do
      request.headers['Authorization'] = "Bearer #{valid_token}"
      
      # Expect User.find to be called only once
      expect(User).to receive(:find).once.and_return(user)
      
      controller.send(:current_user) 
      controller.send(:current_user) 
    end
  end
end