require 'rails_helper'

RSpec.describe RateLimitable, type: :controller do
  # use AuthController as the test subject since it includes RateLimitable
  controller(AuthController) do
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
      # simulate logged in user via signed cookie
      cookies.signed[:jwt] = JWT.encode(
        { user_id: user.id, exp: 10.minutes.from_now.to_i },
        Rails.application.secret_key_base,
        'HS256'
      )

      post :create
      expect(response).to have_http_status(:ok)
    end

    it 'blocks requests over the limit' do
      cookies.signed[:jwt] = JWT.encode(
        { user_id: user.id, exp: 10.minutes.from_now.to_i },
        Rails.application.secret_key_base,
        'HS256'
      )

      5.times { post :create }  # use up the limit
      post :create              # this should be blocked

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
    end
  end
end