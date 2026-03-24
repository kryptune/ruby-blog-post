# spec/services/sliding_window_limiter_spec.rb
require 'rails_helper'

RSpec.describe SlidingWindowLimiter do
  let(:redis) { MockRedis.new }
  let(:user_id) { "user_123" }

  before do
    # replace real Redis with fake one for tests
    allow(Redis).to receive(:new).and_return(redis)
  end

  describe '#allowed?' do
    context 'when under the limit' do
      let(:limiter) { SlidingWindowLimiter.new(limit: 5, window: 60) }

      it 'allows the request' do
        allowed, retry_after = limiter.allowed?(user_id)

        expect(allowed).to be true
        expect(retry_after).to eq 0
      end

      it 'tracks each request' do
        3.times { limiter.allowed?(user_id) }
        allowed, _ = limiter.allowed?(user_id)

        expect(allowed).to be true
      end
    end

    context 'when limit is exceeded' do
      let(:limiter) { SlidingWindowLimiter.new(limit: 3, window: 60) }

      it 'blocks the request' do
        3.times { limiter.allowed?(user_id) }  # use up the limit
        allowed, retry_after = limiter.allowed?(user_id)  # this should be blocked

        expect(allowed).to be false
        expect(retry_after).to be > 0
      end

      it 'returns correct retry_after time' do
        3.times { limiter.allowed?(user_id) }
        _, retry_after = limiter.allowed?(user_id)

        # retry_after should be within the window (60 seconds)
        expect(retry_after).to be_between(1, 60)
      end
    end

    context 'when window expires' do
      let(:limiter) { SlidingWindowLimiter.new(limit: 3, window: 1) } # 1 second window

      it 'resets count after window expires' do
        3.times { limiter.allowed?(user_id) }  # use up the limit

        sleep(1.1)  # wait for window to expire

        allowed, _ = limiter.allowed?(user_id)
        expect(allowed).to be true  # should be allowed again
      end
    end

    context 'with different users' do
      let(:limiter) { SlidingWindowLimiter.new(limit: 3, window: 60) }

      it 'tracks limits separately per user' do
        3.times { limiter.allowed?("user_1") }  # max out user_1
        allowed, _ = limiter.allowed?("user_2")  # user_2 should still be fine

        expect(allowed).to be true
      end
    end
  end
end