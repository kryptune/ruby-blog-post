module Api
  module Authenticate
    extend ActiveSupport::Concern
      include Api::Errorable

      def authenticate
        @current_user = find_user_from_token
        unless @current_user
          unauthorized_req("Unauthorized")
        end

      end
  end
end