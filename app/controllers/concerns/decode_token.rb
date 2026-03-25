module DecodeToken
  extend ActiveSupport::Concern
  def decode_token(header, skip_verification: true)
    JWT.decode(header, ENV['JWT_SECRET_KEY'], skip_verification, algorithm: 'HS256')
  end
end