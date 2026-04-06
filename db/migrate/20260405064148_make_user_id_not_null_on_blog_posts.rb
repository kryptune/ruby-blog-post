class MakeUserIdNotNullOnBlogPosts  < ActiveRecord::Migration[8.1]
	  def up
	    # Enforce NOT NULL constraint
	    change_column_null :blog_posts, :user_id, false
	  end
	
	  def down
	    change_column_null :blog_posts, :user_id, true
  end
end
