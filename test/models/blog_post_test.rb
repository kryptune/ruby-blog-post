require "test_helper"

class BlogPostTest < ActiveSupport::TestCase

  ### MODEL METHODS ###
  test "draft? returns true for draft blog post" do
     assert new_draft.draft?
   end

  test "draft? returns false for published blog post" do
     refute new_published.draft?
   end

  test "draft? returns false for scheduled blog post" do
     refute new_scheduled.draft?
   end

  test "published? returns true for published blog post" do
     assert new_published.published?
   end

  test "published? returns false for draft blog post" do
     refute new_draft.published?
   end

  test "published? returns false for scheduled blog post" do
     refute new_scheduled.published?
   end

  ### VALIDATIONS ###
  test "should not save when title is empty" do 
    post = BlogPost.new(body: "Hello")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
    post.errors.full_messages
  end

  test "should not save when body is empty" do 
    post = BlogPost.new(title: "World")
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
    post.errors.full_messages
  end

  ### SCOPE ###
  test "draft only contains draft blog posts" do
    assert_includes BlogPost.draft, blog_posts(:draft)
    assert_not_includes BlogPost.draft, blog_posts(:published)
    assert_not_includes BlogPost.draft, blog_posts(:scheduled)
   end

  test "scheduled only contains scheduled blog posts" do
    assert_includes BlogPost.scheduled, blog_posts(:scheduled)
    assert_not_includes BlogPost.scheduled, blog_posts(:published)
    assert_not_includes BlogPost.scheduled, blog_posts(:draft)
   end

  test "published only contains published blog posts" do
    assert_includes BlogPost.published, blog_posts(:published)
    assert_not_includes BlogPost.published, blog_posts(:draft)
    assert_not_includes BlogPost.published, blog_posts(:scheduled)
   end
end

def new_draft
  BlogPost.new(published_at: nil)
end

def new_published
  BlogPost.new(published_at: 1.year.ago)
end

def new_scheduled
  BlogPost.new(published_at: 1.year.from_now)
end
