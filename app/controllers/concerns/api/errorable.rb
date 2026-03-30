module Api
  module Errorable
    extend ActiveSupport::Concern

    def unauthorized_req(message)
      render json:{message: message}, status: :unauthorized
    end

  end
end