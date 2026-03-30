Rails.application.config.session_store :cookie_store,
  key: '_blog_session',
  secure: Rails.env.production?,   # only send over HTTPS
  httponly: true,                  # not accessible via JS
  same_site: :lax                  # helps prevent CSRF