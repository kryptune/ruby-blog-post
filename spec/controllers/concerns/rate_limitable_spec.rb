require 'rails_helper'

RSpec.describe RateLimitable, type: :controller do
  # use AuthController as the test subject since it includes RateLimitable
  controller(Web::AuthController) do
    def create
      render json: { message: 'ok' }, status: :ok
    end
  end

  let(:redis) { MockRedis.new }
  let(:user) { create(:user) }

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  describe 'rate limiting by user_id' do
    it 'allows requests under the limit' do
      post :create
      expect(response).to have_http_status(:ok)
    end

    it 'blocks requests over the limit' do
      5.times { post :create }  # use up the limit
      post :create              # this should be blocked
      
      expect(flash[:alert]).to include("Too many attempts. Try again in")
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe 'rate limiting by IP' do
    it 'falls back to IP when no cookie present' do
      # no cookie set, should fall back to IP limiting
      post :create
      expect(response).to have_http_status(:ok)
    end

    it 'blocks IP after limit exceeded' do
      5.times { post :create }
      post :create

      expect(response).to have_http_status(:too_many_requests)
      expect(flash[:alert]).to include("Too many attempts. Try again in")

    end
  end
end