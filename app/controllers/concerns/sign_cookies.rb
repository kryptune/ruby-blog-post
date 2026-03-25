module SignCookies
  extend ActiveSupport::Concern
  def sign_cookies(access, refresh = nil)
    cookies_opts = {
          httponly: true,   # Prevents JavaScript access (XSS protection)
          secure: Rails.env.production?, # Only send over HTTPS in production
          same_site: Rails.env.production? ? :strict : :lax  # strict in prod, lax in dev
          }
    cookies.signed[:jwt] = cookies_opts.merge(value: access)
    cookies.signed[:refresh_jwt] = cookies_opts.merge(value: refresh) if refresh
  end
end