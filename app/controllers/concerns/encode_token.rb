module EncodeToken
  extend ActiveSupport::Concern
    def encode_token(payload)
      JWT.encode(payload, ENV['JWT_SECRET_KEY'], 'HS256')
    end
end