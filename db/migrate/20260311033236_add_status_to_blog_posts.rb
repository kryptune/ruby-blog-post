class AddStatusToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_posts, :status, :string
  end
end
