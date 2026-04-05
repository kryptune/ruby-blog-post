module RateLimitable
  extend ActiveSupport::Concern

  def check_rate_limit(resource)
    rate_limit = case resource
                  when :blog_post
                    { limits: { ip: 20, email: 10, combo: 5 }, window: 1200 } # 20 mins
                  when :comment
                    { limits: { ip: 20, email: 10, combo: 5 }, window: 300 }  # 5 mins
                  when :login, :register
                    { limits: { ip: 10, email: 5, combo: 3 }, window: 600 }   # 10 mins
                  else
                    raise ArgumentError, "Unknown resource: #{resource}"
                  end



    limiter = RedisMultiKeyLimiter.new(**rate_limit.merge(scope: resource))
    #TODO
    allowed, retry_after, message = limiter.allowed?(
      ip: request.remote_ip,
      email: params[:email] || current_user.email
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