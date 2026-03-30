module RateLimitable
  extend ActiveSupport::Concern

  def check_rate_limit
    limiter = RedisMultiKeyLimiter.new(
      limits: { ip: 10, email: 5, combo: 3 },
      window: 600 # 10 minutes
    )

    allowed, retry_after, message = limiter.allowed?(
      ip: request.remote_ip,
      email: params[:email]
    )

    unless allowed
      if request.format.json? || is_api_controller?
        render json: { error: "Too many attempts", retry_after: retry_after }, status: :too_many_requests unless allowed
      else
        render turbo_stream: turbo_stream.replace(
          "flash",
          partial: "shared/flash",
          locals: { alert: "#{message} Try again in #{retry_after > 60 ? "#{retry_after / 60} minutes" : "#{retry_after} seconds"}." }
        ), status: :too_many_requests
      end
    end
  end

  
  private

  def is_api_controller?
    self.class < ActionController::API
  end

end