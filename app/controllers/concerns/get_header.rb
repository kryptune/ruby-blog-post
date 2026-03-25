module GetHeader
  extend ActiveSupport::Concern
   
  def getHeader
    cookies.signed[:jwt] || extract_bearer_token
  end

  private

  def extract_bearer_token(header: "Authorization")
    token = request.headers[header]
    token&.start_with?("Bearer ") ? token.split(" ").last : nil
  end
end