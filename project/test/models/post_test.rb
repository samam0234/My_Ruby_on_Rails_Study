require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires a title" do
    post = Post.new(title: "", body: "본문")

    assert_not post.valid?
    assert post.errors[:title].any?
  end

  test "fixture post can be found" do
    assert_equal "첫 글", posts(:hello).title
  end

  test "destroying a post destroys its comments" do
    assert_difference -> { Comment.count }, -1 do
      posts(:hello).destroy
    end
  end

  test "author can be read from the post" do
    assert_equal users(:mina), posts(:hello).user
    assert_includes users(:mina).posts, posts(:hello)
  end
end
