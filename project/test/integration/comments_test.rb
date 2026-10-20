require "test_helper"

class CommentsTest < ActionDispatch::IntegrationTest
  test "show lists the comment and its author" do
    get post_path(posts(:hello))

    assert_response :success
    assert_select "article.comment", text: /첫 댓글입니다/
    assert_select "p.meta", text: /미나/
  end

  test "create requires login" do
    post post_comments_path(posts(:hello)), params: { comment: { body: "하나 더" } }

    assert_redirected_to login_path
  end

  test "create adds a comment by the logged in user" do
    log_in_as users(:jun)

    assert_difference -> { posts(:hello).comments.count }, 1 do
      post post_comments_path(posts(:hello)), params: { comment: { body: "하나 더" } }
    end

    assert_equal users(:jun), Comment.order(:id).last.user
    assert_redirected_to posts(:hello)
  end

  test "create rejects a blank comment" do
    log_in_as users(:mina)

    assert_no_difference -> { Comment.count } do
      post post_comments_path(posts(:hello)), params: { comment: { body: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "another user cannot delete the comment" do
    log_in_as users(:jun)
    delete post_comment_path(posts(:hello), comments(:on_hello))

    assert_redirected_to posts(:hello)
    assert Comment.exists?(comments(:on_hello).id)
  end
end
