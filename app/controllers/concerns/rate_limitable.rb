module RateLimitable
  extend ActiveSupport::Concern

  def check_rate_limit(limit:, window:)
    user_id = identify_user_for_limit
    limiter = SlidingWindowLimiter.new(limit: limit, window: window)
    allowed, retry_after = limiter.allowed?(user_id)

    unless allowed
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash",
            partial: "shared/flash",
            locals: { alert: "Too many attempts. Try again in #{retry_after > 60 ? "#{retry_after / 60} minutes" : "#{retry_after} seconds"}." }
          ), status: :too_many_requests
        end

        format.html do
          flash.now[:alert] = "Too many attempts. Try again in #{retry_after > 60 ? "#{retry_after / 60} minutes" : "#{retry_after} seconds"}."
          render :login, status: :too_many_requests
        end

        format.json do
          render json: {
            error: "Too many attempts",
            retry_after: retry_after
          }, status: :too_many_requests
        end
      end
      return
    end
  end
  private

  def identify_user_for_limit
    request.ip
  rescue JWT::DecodeError, JWT::ExpiredSignature, TypeError
    request.ip
  end
end