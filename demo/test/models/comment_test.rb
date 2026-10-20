require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "belongs to a post" do
    comment = comments(:on_hello)

    assert_equal posts(:hello), comment.post
  end

  test "requires a body" do
    comment = Comment.new(post: posts(:hello), body: "")

    assert_not comment.valid?
  end
end
