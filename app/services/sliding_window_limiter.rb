class SlidingWindowLimiter
  def initialize(limit:, window:)
    # remove @app, no longer a middleware
    @limit = limit
    @window = window
    @redis = Redis.new
  end

  def allowed?(user_id)
    key = "rate_limit:#{user_id}:#{@limit}:#{@window}"
    now = Time.now.to_f

    @redis.zremrangebyscore(key, 0, now - @window)
    @redis.zadd(key, now, now)
    count = @redis.zcard(key)
    @redis.expire(key, @window)

    if count <= @limit
      [true, 0]
    else
      oldest = @redis.zrange(key, 0, 0, withscores: true).first&.last
      retry_after = (oldest + @window - now).ceil
      [false, retry_after]
    end
  end
end