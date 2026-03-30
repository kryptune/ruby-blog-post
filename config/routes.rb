Rails.application.routes.draw do
  draw :api_routes
  draw :web_routes
  draw :comment_routes
  draw :blog_post_routes
  draw :session_routes

  root "web/auth#login"
  mount LetterOpenerWeb::Engine, at: "/letter_opener"

  def draw(route_file)
    instance_eval(File.read(Rails.root.join("config/routes/#{route_file}.rb")))
  end

end
