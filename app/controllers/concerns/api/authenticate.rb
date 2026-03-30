module Api
  module Authenticate
    extend ActiveSupport::Concern
      def authenticate
        raw_token = get_header_token
        unauthorized_req("Token not found") unless raw_token
        begin
          decoded_token = decode_token(raw_token)
          @current_user = User.find(decoded_token[0]["user_id"])
        rescue JWT::ExpiredSignature
          unauthorized_req("Expired Signature")
        rescue JWT::DecodeError
          unauthorized_req("Invalid Token")
        end
      end
  end
end