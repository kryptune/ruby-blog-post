module Api
  module ApiTokenManager
    extend ActiveSupport::Concern

    def encode_token(payload)
      JWT.encode(payload, ENV['JWT_SECRET_KEY'], 'HS256')
    end

    def decode_token(header_token, verification: true)
      JWT.decode(header_token, ENV['JWT_SECRET_KEY'], verification, algorithm: 'HS256')
    end

    def generate_tokens(user)
      access_token  = encode_token({ user_id: user.id, exp: 10.minutes.from_now.to_i })
      exp = (params[:remember_me] == "1" ? 30 : 7).days.from_now.to_i
      refresh_token  = encode_token({ user_id: user.id, exp: exp })
      [access_token, refresh_token]
    end

    def get_header_token(header: "Authorization")
      token = request.headers[header]
      token&.start_with?("Bearer ") ? token.split(" ").last : nil
    end

    def json_opts(message, access_token, refresh_token = nil, user: nil, status: :ok)
      {
        json: {
          message: message,
          access_token: access_token,
          refresh_token: refresh_token,
          user: user&.as_json(only: [:id, :email, :name])
        }.compact,
        status: status
      }
    end

    def save_session(user)
      session[:user_id] = user.id
      user.sessions.create!(
        session_token: get_session_id, # Rails' internal session ID
        device_info: request.user_agent,
        ip_address: request.remote_ip,
        expires_at: (params[:remember_me] == "1" ? 30 : 7).days.from_now
      )
    end

    def find_user_from_token
      token = get_header_token
      return nil unless token
      begin
        decoded = decode_token(token)
        User.find_by(id: decoded[0]["user_id"])
      rescue JWT::ExpiredSignature, JWT::DecodeError
        render json: { error: "Session expired or invalid" }, status: :unauthorized
        nil
      end
    end
  end
end