require "test_helper"

class CommentsTest < ActionDispatch::IntegrationTest
  test "show lists the comment and its author" do
    get post_path(posts(:hello))

    assert_response :success
    assert_select "article.comment", text: /첫 댓글입니다/
    assert_select "p.meta", text: /미나/
  end

  test "create adds a comment" do
    assert_difference -> { posts(:hello).comments.count }, 1 do
      post post_comments_path(posts(:hello)), params: { comment: { body: "하나 더" } }
    end

    assert_redirected_to posts(:hello)
  end

  test "create rejects a blank comment" do
    assert_no_difference -> { Comment.count } do
      post post_comments_path(posts(:hello)), params: { comment: { body: "" } }
    end

    assert_response :unprocessable_entity
  end
end
