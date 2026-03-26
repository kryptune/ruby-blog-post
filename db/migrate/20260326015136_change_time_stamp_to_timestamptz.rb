class ChangeTimeStampToTimestamptz < ActiveRecord::Migration[8.1]
  def change
    tables = [:users, :blog_posts, :comments]
    tables.each do |table|
          change_column table, :created_at, :timestamptz
          change_column table, :updated_at, :timestamptz
        end
    change_column :blog_posts, :published_at, :timestamptz
  end

end
