json.message "Blog post was successfully deleted."

json.extract! @blog_post, :id, :title, :body, :created_at, :updated_at
