class ChangeStatusToIntegerInBlogPosts < ActiveRecord::Migration[8.1]
  def up
    # convert existing string values to integer
    change_column :blog_posts, :status, "integer USING CAST(status AS integer)"
  end

  def down
    change_column :blog_posts, :status, :string
  end
end
