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
end
