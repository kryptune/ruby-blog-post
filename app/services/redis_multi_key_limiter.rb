class RedisMultiKeyLimiter
  def initialize(limits:, window:, scope:)
    @limits = limits
    @window = window
    @scope = scope
    @redis = Redis.new
  end

  def allowed?(ip:, email:)
    email = email.to_s.downcase
    ip_key    = "#{@scope}:ip:#{ip}"
    email_key = "#{@scope}:email:#{email}"
    combo_key = "#{@scope}:combo:#{ip}:#{email}"

    results = {
      ip:    increment_with_expiry(ip_key),
      email: increment_with_expiry(email_key),
      combo: increment_with_expiry(combo_key)
    }

    # Check limits
    if results[:ip] > @limits[:ip]
      return [false, @redis.ttl(ip_key), "Too many attempts from this IP."]
    elsif results[:email] > @limits[:email]
      return [false, @redis.ttl(email_key), "Too many attempts for this account."]
    elsif results[:combo] > @limits[:combo]
      return [false, @redis.ttl(combo_key), "Too many attempts for this email from this IP."]
    else
      return [true, nil, nil]
    end
  end

  private

  def increment_with_expiry(key)
    count = @redis.incr(key)
    if count == 1
      @redis.expire(key, @window)
    end
    count
  end
end