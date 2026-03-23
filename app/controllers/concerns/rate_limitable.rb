module RateLimitable
  extend ActiveSupport::Concern

  def check_rate_limit(limit:, window:)
    user_id = identify_user_for_limit
    limiter = SlidingWindowLimiter.new(limit: limit, window: window)
    allowed, retry_after = limiter.allowed?(user_id)

    unless allowed
      render json: {
        error: 'Too Many Requests',
        message: "Rate limit exceeded. Try again in #{retry_after} seconds."
      }, status: :too_many_requests,
      headers: { 'Retry-After' => retry_after.to_s }
    end
  end

  private

  def identify_user_for_limit
    decoded = JWT.decode(
      cookies.signed[:jwt],
      Rails.application.secret_key_base,
      true,
      algorithm: 'HS256'
    )
    decoded.first["user_id"].to_s
  rescue JWT::DecodeError, JWT::ExpiredSignature, TypeError
    request.ip
  end
end