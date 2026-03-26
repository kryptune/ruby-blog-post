require 'rails_helper'

RSpec.describe TokenManager, type: :controller do
  controller(ApplicationController) do
    def index
      render json: { message: "ok" }, status: :ok
    end
  end

  let(:user) { create(:user) }
  let(:refresh_token) do
    JWT.encode(
      { user_id: user.id, exp: 7.days.from_now.to_i },
      ENV['JWT_SECRET_KEY'], 'HS256'
    )
  end
  let(:expired_refresh_token) do
    JWT.encode(
      { user_id: user.id, exp: 1.minute.ago.to_i },
      ENV['JWT_SECRET_KEY'], 'HS256'
    )
  end
  let(:expired_token) { JWT.encode({ user_id: user.id, exp: 1.minute.ago.to_i }, ENV['JWT_SECRET_KEY'], 'HS256') }


  describe "#refresh_access_token" do
    context "when refresh token is valid" do
      it "sets a new access token cookie" do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, refresh_token])
        get :index, format: :json

        expect(cookies.signed[:jwt]).to be_present
      end

      it "sets X-New-Access-Token response header for mobile" do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, refresh_token])
        get :index, format: :json
        expect(response.headers["X-New-Access-Token"]).to be_present
      end

      it "sets @current_user" do
        controller.send(:refresh_access_token, user, refresh_token)
        expect(controller.instance_variable_get(:@current_user)).to eq(user)
      end

      it "new access token belongs to correct user" do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, refresh_token])
        get :index, format: :json
        new_token = response.headers["X-New-Access-Token"]
        decoded = JWT.decode(new_token, ENV['JWT_SECRET_KEY'], true, algorithm: 'HS256')
        expect(decoded[0]["user_id"]).to eq(user.id)
      end
    end

    context "when refresh token is expired" do
      it "clears refresh token from DB" do
        user.update_columns(refresh_token: expired_refresh_token)
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, expired_refresh_token])
        get :index, format: :json
        expect(user.reload.refresh_token).to be_nil
      end

      it "clears refresh cookie" do
        cookies.signed[:refresh_jwt] = expired_refresh_token
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, expired_refresh_token])
        get :index, format: :html
        expect(cookies[:refresh_jwt]).to be_nil
      end

      it "renders session expired flash" do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, expired_refresh_token])
        get :index, format: :html
        expect(flash[:alert]).to include("Session expired")
      end
    end

    context "when refresh token is invalid" do
      it "renders invalid refresh token flash" do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, "invalid.token"])
        get :index, format: :html
        expect(flash[:alert]).to include("Invalid refresh token")
      end

      it "clears tokens" do
        user.update_columns(refresh_token: "invalid.token")
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(controller).to receive(:get_refresh_token).and_return([user, "invalid.token"])        
        get :index, format: :html
        expect(user.reload.refresh_token).to be_nil
      end
    end
  end
end